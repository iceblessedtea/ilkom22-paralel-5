require 'sinatra'
require 'json'
require 'net/http'
require 'uri'
require 'sequel'
require 'concurrent'
require 'logger'
require 'puma'

# Explicitly set Sinatra environment to production for better performance
set :environment, ENV.fetch('RACK_ENV', 'development').to_sym
set :server, :puma

PATIENT_URL = ENV.fetch('PATIENT_URL', 'http://localhost:7860')
DOCTOR_URL = ENV.fetch('DOCTOR_URL', 'http://localhost:7861')
DATABASE_URL = ENV.fetch('DATABASE_URL', 'postgres://healthcare:healthcare@localhost:5432/appointment_service')

module AppointmentService
  class API < Sinatra::Base
    HttpResponse = Struct.new(:status, :body)

    # Configure thread-safe database connection
    DB = Sequel.connect(DATABASE_URL, 
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

    def self.http_get(url)
      response = Net::HTTP.get_response(URI(url))
      HttpResponse.new(response.code.to_i, response.body)
    end

    # Root endpoint to check service health
    get '/' do
      begin
        # Ambil data dari service Patient dan Doctor
        patient_response = self.class.http_get("#{PATIENT_URL}/patients")
        doctor_response = self.class.http_get("#{DOCTOR_URL}/doctors")
    
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

    get '/health' do
      content_type :json
      { status: 'ok', service: 'appointment-service' }.to_json
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
        appointment_query = DB[:appointments]
        appointment_query = appointment_query.where(doctor_id: params['doctor_id'].to_i) if params['doctor_id']
        appointment_query = appointment_query.where(patient_id: params['patient_id'].to_i) if params['patient_id']
        appointments = appointment_query.all
        if appointments.empty?
          content_type :json
          return [].to_json
        end
        appointments_data = Concurrent::Array.new
        semaphore = Concurrent::Semaphore.new(5)
        threads = appointments.map do |appointment|
          Thread.new do
            semaphore.acquire
            begin
              patient_response = self.class.http_get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
              doctor_response = self.class.http_get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
              doctor_schedule_response = self.class.http_get("#{DOCTOR_URL}/schedules")
              timeslot_response = self.class.http_get("#{DOCTOR_URL}/timeslots")
              room_response = self.class.http_get("#{DOCTOR_URL}/rooms")
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

    get '/appointments/by-doctor/:doctor_id' do
      call env.merge(
        'PATH_INFO' => '/appointments',
        'QUERY_STRING' => "doctor_id=#{params['doctor_id']}"
      )
    end

    get '/appointments/by-patient/:patient_id' do
      call env.merge(
        'PATH_INFO' => '/appointments',
        'QUERY_STRING' => "patient_id=#{params['patient_id']}"
      )
    end

    get '/appointments/doctor/:doctor_id' do
      call env.merge(
        'PATH_INFO' => '/appointments',
        'QUERY_STRING' => "doctor_id=#{params['doctor_id']}"
      )
    end

    get '/appointments/patients/:patient_id' do
      call env.merge(
        'PATH_INFO' => '/appointments',
        'QUERY_STRING' => "patient_id=#{params['patient_id']}"
      )
    end

    # Get an appointment by ID
    get '/appointments/:id' do
      appointment = DB[:appointments].where(id: params['id']).first
      if appointment
        begin
          patient_response = self.class.http_get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
          doctor_response = self.class.http_get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
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

    # Legacy implementation kept for reference, but canonical routes above handle these paths first.
    get '/legacy/appointments/doctor/:doctor_id' do
      doctor_id = params['doctor_id'].to_i
    
      # Ambil janji temu untuk doctor_id
      appointments_for_doctor = DB[:appointments].where(doctor_id: doctor_id).all
    
      if appointments_for_doctor.empty?
        status 404
        content_type :json
        { error: "No appointments found for doctor ID #{doctor_id}" }.to_json
      else
        # Ambil data dokter dari service dokter
        doctor_response = self.class.http_get("#{DOCTOR_URL}/doctors/#{doctor_id}")
        if doctor_response.status == 200
          doctor_data = JSON.parse(doctor_response.body.to_s)
        else
          status 500
          content_type :json
          return { error: "Failed to fetch doctor data for doctor ID #{doctor_id}" }.to_json
        end
    
        # Proses janji temu
        appointments_data = appointments_for_doctor.map do |appointment|
          # Ambil data pasien dari service pasien
          patient_response = self.class.http_get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
          if patient_response.status == 200
            patient_data = JSON.parse(patient_response.body.to_s)
            {
              appointment_id: appointment[:id],
              patient_name: patient_data["patient"]["name"],
              doctor: doctor_data,
              date: appointment[:date]
            }
          else
            # Berikan informasi jika data pasien gagal diambil
            {
              appointment_id: appointment[:id],
              patient: { error: "Failed to fetch patient data for patient ID #{appointment[:patient_id]}" },
              doctor: doctor_data,
              date: appointment[:date]
            }
          end
        end
    
        status 200
        content_type :json
        appointments_data.to_json
      end
    end
    

    get '/legacy/appointments/patients/:patient_id' do
      patient_id = params['patient_id'].to_i
      appointments_for_patient = DB[:appointments].where(patient_id: patient_id).all
      if appointments_for_patient.empty?
        status 404
        { error: "No appointments found for patient ID #{patient_id}" }.to_json
      else
        appointments_data = appointments_for_patient.map do |appointment|
          doctor_response = self.class.http_get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
          patient_response = self.class.http_get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
          if doctor_response.status == 200 && patient_response.status == 200
            doctor_data = JSON.parse(doctor_response.body.to_s)
            patient_data = JSON.parse(patient_response.body.to_s)
            {
              appointment_id: appointment[:id],
              patient:patient_data,
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
          '/appointments?doctor_id=:doctor_id': 'Get appointments by doctor ID',
          '/appointments?patient_id=:patient_id': 'Get appointments by patient ID',
          '/appointments/by-doctor/:doctor_id': 'Get appointments by doctor ID',
          '/appointments/by-patient/:patient_id': 'Get appointments by patient ID'
        }
      }.to_json
    end
  end
end
