require 'sinatra'
require 'json'
require 'httpx'
require 'sequel'
require 'concurrent'
require 'logger'
require 'puma'

# Explicitly set Sinatra environment to production for better performance
set :environment, :production
set :server, :puma

PATIENT_URL = "http://127.0.0.1:7860"
DOCTOR_URL = "http://127.0.0.1:7861"

module AppointmentService
  class API < Sinatra::Base
    # Configure thread-safe database connection
    DB = Sequel.connect('sqlite://db/new_appointments.db', 
      max_connections: 10, 
      pool_timeout: 10
    )
    
    # Create a thread pool for external API calls
    API_THREAD_POOL = Concurrent::FixedThreadPool.new(10)

    # Thread-safe logger
    LOGGER = Logger.new(STDOUT)
    LOGGER.level = Logger::INFO

    # Synchronization primitive for critical sections
    MUTEX = Mutex.new

    # Root endpoint to check service health
    get '/' do
      begin
        # Ambil data dari service Patient dan Doctor
        patient_response = HTTPX.get("#{PATIENT_URL}/patients")
        doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors")
    
        # Status masing-masing service dalam format JSON
        doctor_message = if doctor_response.status == 200
                           { message: "Service Doctors berjalan dengan baik" }
                         else
                           { message: "Service Doctors gagal dengan status #{doctor_response.status}" }
                         end.to_json
    
        patient_message = if patient_response.status == 200
                            { message: "Service Patients berjalan dengan baik" }
                          else
                            { message: "Service Patients gagal dengan status #{patient_response.status}" }
                          end.to_json
    
        appointment_message = { message: "Service Appointments berjalan dengan baik" }.to_json
    
        # Gabungkan semua pesan dengan newline untuk tampil terpisah
        response_text = "#{doctor_message}\n#{patient_message}\n#{appointment_message}"
    
        status 200
        response_text
      rescue => e
        # Jika terjadi error
        status 500
        { message: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end
    

    # Create a new appointment
    post '/appointments' do
      begin
        appointment_data = JSON.parse(request.body.read)
        new_appointment = MUTEX.synchronize do
          DB[:appointments].insert(
            patient_id: appointment_data["patient_id"],
            doctor_id: appointment_data["doctor_id"],
            date: appointment_data["date"],
            notes: appointment_data["notes"],
            created_at: Time.now,
            updated_at: Time.now
          )
        end
        status 201
        { success: true, appointment_id: new_appointment }.to_json
      rescue => e
        LOGGER.error("Error creating appointment: #{e.message}")
        status 500
        { error: "Failed to create appointment: #{e.message}" }.to_json
      end
    end

    # Update an existing appointment
    put '/appointments/:id' do
      begin
        appointment_data = JSON.parse(request.body.read)
        updated = MUTEX.synchronize do
          DB[:appointments].where(id: params['id']).update(
            notes: appointment_data["notes"],
            updated_at: Time.now
          )
        end
        if updated > 0
          status 200
          { success: true }.to_json
        else
          status 404
          { error: "Appointment not found" }.to_json
        end
      rescue => e
        LOGGER.error("Error updating appointment: #{e.message}")
        status 500
        { error: "Failed to update appointment: #{e.message}" }.to_json
      end
    end

    # Delete an appointment
    delete '/appointments/:id' do
      begin
        deleted = MUTEX.synchronize do
          DB[:appointments].where(id: params['id']).delete
        end
        if deleted > 0
          status 204
        else
          status 404
          { error: "Appointment not found" }.to_json
        end
      rescue => e
        LOGGER.error("Error deleting appointment: #{e.message}")
        status 500
        { error: "Failed to delete appointment: #{e.message}" }.to_json
      end
    end

    # Get all appointments
    get '/appointments' do
      begin
        appointments = DB[:appointments].all
        if appointments.empty?
          status 404
          return { error: "No appointments found" }.to_json
        end
        appointments_data = Concurrent::Array.new
        semaphore = Concurrent::Semaphore.new(5)
        threads = appointments.map do |appointment|
          Thread.new do
            semaphore.acquire
            begin
              patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
              doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
              doctor_schedule_response = HTTPX.get("#{DOCTOR_URL}/schedules")
              timeslot_response = HTTPX.get("#{DOCTOR_URL}/timeslots")
              room_response = HTTPX.get("#{DOCTOR_URL}/rooms")
              if patient_response.status == 200 && doctor_response.status == 200
                patient_data = JSON.parse(patient_response.body.to_s)
                doctor_data = JSON.parse(doctor_response.body.to_s)
                # Parsing data dari respons
                patient_data = JSON.parse(patient_response.body.to_s)
                doctor_data = JSON.parse(doctor_response.body.to_s)
                schedules = JSON.parse(doctor_schedule_response.body.to_s) if doctor_schedule_response.status == 200
                timeslots = JSON.parse(timeslot_response.body.to_s) if timeslot_response.status == 200
                rooms = JSON.parse(room_response.body.to_s) if room_response.status == 200
                
                # Mencari schedule berdasarkan doctor_id dan appointment date
                require 'time'

                schedule_data = schedules&.find do |s|
                  appointment_date = appointment[:date].to_date.to_s  # Mengubah DateTime menjadi Date
                  schedule_date = s["date"].to_s  # Mengubah Date menjadi String
                  appointment_date == schedule_date && s["doctor_id"] == appointment[:doctor_id]
                end
                

                # schedule_data = schedules&.find { |s| s["doctor_id"] == appointment[:doctor_id]}

                timeslot_data = if schedule_data
                  timeslots&.find { |t| t["id"] == schedule_data["timeslot_id"] }
                end
                # Mengambil data room dari schedule
                room_data = if schedule_data
                  rooms&.find { |r| r["id"] == schedule_data["room_id"] }
                end
                appointments_data << {
                  appointment_id: appointment[:id],
                  patient_id: appointment[:patient_id],
                  patient_name: patient_data["patient"]["name"],
                  doctor_id: appointment[:doctor_id],
                  doctor_name: doctor_data["name"],
                  date: appointment[:date],
                  notes: appointment[:notes],
                  room_name: room_data ? room_data["name"] : "Unknown Room",
                  timeslot: timeslot_data ? {
                    day: timeslot_data["day"],
                    start_time: timeslot_data["start_time"],
                    end_time: timeslot_data["end_time"]
                  } : "Unknown Timeslot"
                }
              end.compact
            rescue => e
              LOGGER.error("Error fetching appointment data: #{e.message}")
            ensure
              semaphore.release
            end
          end
        end
        threads.each(&:join)
        content_type :json
        appointments_data.to_json
      rescue => e
        LOGGER.error("Error fetching appointments: #{e.message}")
        status 500
        { error: "Failed to fetch appointments: #{e.message}" }.to_json
      end
    end

    # Get an appointment by ID
    get '/appointments/:id' do
      appointment = DB[:appointments].where(id: params['id']).first
      if appointment
        begin
          patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
          doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
          if patient_response.status == 200 && doctor_response.status == 200
            patient_data = JSON.parse(patient_response.body.to_s)
            doctor_data = JSON.parse(doctor_response.body.to_s)
            content_type :json
            {
              id: appointment[:id],
              patient: patient_data,
              doctor: doctor_data,
              date: appointment[:date],
              created_at: appointment[:created_at]
            }.to_json
          else
            status 500
            { error: "Failed to fetch related data" }.to_json
          end
        rescue => e
          status 500
          { error: "Error fetching related data: #{e.message}" }.to_json
        end
      else
        status 404
        { error: "Appointment not found" }.to_json
      end
    end

    # Get appointments by doctor ID
    get '/appointments/doctor/:doctor_id' do
      doctor_id = params['doctor_id'].to_i
      appointments_for_doctor = DB[:appointments].where(doctor_id: doctor_id).all
      if appointments_for_doctor.empty?
        status 404
        { error: "No appointments found for doctor ID #{doctor_id}" }.to_json
      else
        appointments_data = appointments_for_doctor.map do |appointment|
          patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
          if patient_response.status == 200
            patient_data = JSON.parse(patient_response.body.to_s)
            {
              appointment_id: appointment[:id],
              patient_id: appointment[:patient_id],
              patient_name: patient_data["patient"]["name"],
              doctor_id: appointment[:doctor_id],
              date: appointment[:date]
            }
          else
            nil
          end
        end.compact
        content_type :json
        appointments_data.to_json
      end
    end

    # Get appointments by patient ID
    get '/appointments/patients/:patient_id' do
      patient_id = params['patient_id'].to_i
      appointments_for_patient = DB[:appointments].where(patient_id: patient_id).all
      if appointments_for_patient.empty?
        status 404
        { error: "No appointments found for patient ID #{patient_id}" }.to_json
      else
        appointments_data = appointments_for_patient.map do |appointment|
          doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
          if doctor_response.status == 200
            doctor_data = JSON.parse(doctor_response.body.to_s)
            {
              appointment_id: appointment[:id],
              doctor_id: appointment[:doctor_id],
              doctor_name: doctor_data["name"],
              date: appointment[:date],
              notes: appointment[:notes]
            }
          else
            nil
          end
        end.compact
        content_type :json
        appointments_data.to_json
      end
    end

    # API documentation
    get '/docs' do
      content_type :json
      {
        endpoints: {
          '/': 'Check service health',
          '/appointments': 'CRUD operations for appointments',
          '/appointments/:id': 'Get details of an appointment',
          '/appointments/doctor/:doctor_id': 'Get appointments by doctor ID',
          '/appointments/patients/:patient_id': 'Get appointments by patient ID'
        }
      }.to_json
    end
  end
end
