  require 'sinatra'
  require 'json'
  require 'httpx'
  require 'sequel'

  PATIENT_URL = "http://127.0.0.1:7860"
  DOCTOR_URL = "http://127.0.0.1:7861"
  # RM_URL = "http://127.0.0.1:7863"

  module AppointmentService
    class API < Sinatra::Base
      DB = Sequel.connect('sqlite://db/new_appointments.db')


      get '/' do
        begin
          patient_response = HTTPX.get("#{PATIENT_URL}/patients")
          # Panggil API Doctor Service untuk mendapatkan data dokter
          doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors")
          # Panggil API Doctor Service untuk mendapatkan Schedule 
          doctor_schedule_response = HTTPX.get("#{DOCTOR_URL}/schedules")

          timeslot_response = HTTPX.get("#{DOCTOR_URL}/timeslots")
          room_response = HTTPX.get("#{DOCTOR_URL}/rooms")

          patients = JSON.parse(patient_response.body.to_s) if patient_response.status == 200
          doctors = JSON.parse(doctor_response.body.to_s) if doctor_response.status == 200
          schedules = JSON.parse(doctor_schedule_response.body.to_s) if doctor_schedule_response.status == 200
          timeslots = JSON.parse(timeslot_response.body.to_s) if timeslot_response.status == 200
          rooms = JSON.parse(room_response.body.to_s) if room_response.status == 200

          # Cek apakah semua data berhasil diambil
          unless patients
            status 500
            return { error: "Gagal mengambil data pasien dari service Patient." }.to_json
          end

          unless doctors
            status 500
            return { error: "Gagal mengambil data dokter dari service Doctor." }.to_json
          end

          unless schedules
            status 500
            return { error: "Gagal mengambil data jadwal dari service Doctor." }.to_json
          end
          unless timeslots
            status 500
            return { error: "Gagal mengambil data timeslot dari service Doctor." }.to_json
          end
          
          unless rooms
            status 500
            return { error: "Gagal mengambil data room dari service Doctor." }.to_json
          end
          

          data = doctors.map do |doctor|
            doctor_schedules = schedules.select { |s| s["doctor_id"] == doctor["id"] }
            
            {
              doctor_id: doctor["id"],
              name: doctor["name"],
              specialization: doctor["specialization"],
              schedules: doctor_schedules.map do |s| 
                timeslot = timeslots.find { |t| t["id"] == s["timeslot_id"] }
                room = rooms.find { |r| r["id"] == s["room_id"] }
                
                {
                  date: s["date"],
                  room_name: room ? room["name"] : "Unknown Room",
                  timeslot_name: timeslot ? timeslot["name"] : "Unknown Timeslot"
                }
              end
            }
          end

          content_type :json
          {
            message: "Service janjitemu berjalan dengan baik",
            data: data
          }.to_json
        rescue => e
          status 500
          { error: "Gagal berkomunikasi dengan service lain: #{e.message}" }.to_json
        end
      end

      post '/appointments' do
        begin
          appointment_data = JSON.parse(request.body.read)
          puts "Received appointment data: #{appointment_data}"


          new_appointment = DB[:appointments].insert(
            patient_id: appointment_data["patient_id"],
            doctor_id: appointment_data["doctor_id"],
            date: appointment_data["date"],
            notes: appointment_data["notes"],
            created_at: Time.now,
            updated_at: Time.now
          )
          

          status 201
          { success: true, appointment_id: new_appointment }.to_json
        rescue JSON::ParserError => e
          status 400
          { error: "Invalid JSON payload: #{e.message}" }.to_json
        rescue => e
          status 500
          { error: "Error processing request: #{e.message}" }.to_json
        end
      end

      put '/appointments/:id' do
        appointment_data = JSON.parse(request.body.read)
        updated = DB[:appointments].where(id: params['id']).update(
            notes: appointment_data["notes"],
            updated_at: Time.now
        )
        
        if updated > 0
            status 200
            { success: true }.to_json
        else
            status 404
            { error: "Appointment not found" }.to_json
        end
      end
      
      delete '/appointments/:id' do
        deleted = DB[:appointments].where(id: params['id']).delete
        
        if deleted > 0
            status 204 # No Content response for successful deletion.
        else
            status 404
            { error: "Appointment not found" }.to_json
        end
      end
      
      
      get '/appointments' do
        appointments = DB[:appointments].all
        if appointments.empty?
          status 404
            { error: "No appointments found" }.to_json
          else
            appointments_data = appointments.map do |appointment|
              patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
              doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
              unless patient_response.status == 200 && doctor_response.status == 200
                    puts "Error fetching data: Patient response status #{patient_response.status}, Doctor response status #{doctor_response.status}"
                    next # Skip this appointment if there's an error
                  end
                  
                patient_data = JSON.parse(patient_response.body.to_s)
                doctor_data = JSON.parse(doctor_response.body.to_s)
                patient_name = patient_data["patient"]["name"]
                {
                    appointment_id: appointment[:id],
                    patient_id: appointment[:patient_id],
                    patient_name: patient_name,
                    doctor_id: appointment[:doctor_id],
                    doctor_name: doctor_data["name"],
                    date: appointment[:date],
                    notes: appointment[:notes],
                    created_at: appointment[:created_at]
                  }
                end.compact
            
            content_type :json
            appointments_data.to_json
          end
        end
      
        
      get '/appointments/:id' do
        appointment = DB[:appointments].where(id: params['id']).first
        if appointment
          begin
            # Ambil data pasien
            patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
            doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
            
            if patient_response.status != 200 || doctor_response.status != 200
              status 500
              return { error: "Failed to fetch related data" }.to_json
            end

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
          rescue => e
            status 500
            { error: "Error fetching related data: #{e.message}" }.to_json
          end
        else
          status 404
          { error: "Appointment not found" }.to_json
        end
      end
      

      get '/appointments/doctor/:doctor_id' do
        doctor_id = params['doctor_id'].to_i

        # Filter janji temu berdasarkan doctor_id
        appointments_for_doctor = DB[:appointments].where(doctor_id: doctor_id).all

        if appointments_for_doctor.empty?
          status 404
          { error: "No appointments found for doctor ID #{doctor_id}" }.to_json
        else
          appointments_for_doctor_data = appointments_for_doctor.map do |appointment|
            patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
            doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
            
            if patient_response.status == 200 && doctor_response.status == 200
              patient_data = JSON.parse(patient_response.body.to_s)
              doctor_data = JSON.parse(doctor_response.body.to_s)
              patient_name = patient_data["patient"]["name"]

              {
                appointment_id: appointment[:id],
                patient_id: appointment[:patient_id],
                patient_name: patient_name,
                doctor_id: appointment[:doctor_id],
                doctor_name: doctor_data["name"],  # Mengambil nama dokter dari data dokter
                date: appointment[:date],
                created_at: appointment[:created_at]
              }
            else
              nil
            end
          end.compact
          

          content_type :json
          appointments_for_doctor_data.to_json
        end
      end
        
    
      get '/appointments/patients/:patient_id' do
        patient_id = params['patient_id'].to_i
        
        # Filter janji temu berdasarkan patient_id
        appointments_for_patient = DB[:appointments].where(patient_id: patient_id).all
      
        if appointments_for_patient.empty?
          status 404
          { error: "No appointments found for patient ID #{patient_id}" }.to_json
        else
          appointments_for_patient_data = appointments_for_patient.map do |appointment|
            # Ambil data pasien (meskipun sudah ada dalam janji temu, jika diperlukan)
            patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
            # Ambil data dokter
            doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
            
            medical_record_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}/records")

            if patient_response.status == 200 && doctor_response.status == 200
              patient_data = JSON.parse(patient_response.body.to_s)
              doctor_data = JSON.parse(doctor_response.body.to_s)
              medical_record = if medical_record_response.status == 200
                JSON.parse(medical_record_response.body.to_s)["medical_record"]
              else
                { note: "Medical record not available", details: [] } # Placeholder rekam medis
              end
              patient_name = patient_data["patient"]["name"]
              {
                appointment_id: appointment[:id],
                patient_id: appointment[:patient_id],
                patient_name: patient_name,
                doctor_id: appointment[:doctor_id],
                doctor_name: doctor_data["name"],
                date: appointment[:date],
                created_at: appointment[:created_at],
                medical_record: medical_record
              }
            else
              nil
            end
          end.compact
      
          content_type :json
          appointments_for_patient_data.to_json
        end
      end

      get '/docs' do
        content_type :json
        {
          endpoints: {
            '/': 'Get service status',
            '/appointments': 'CRUD operations for appointments',
            '/appointments/:id': 'Get details of an appointment',
            '/appointments/doctor/:doctor_id': 'Get appointments for a doctor',
            '/appointments/patients/:patient_id': 'Get appointments for a patient'
          }
        }.to_json
      end

    end
  end
