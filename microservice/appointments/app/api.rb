  require 'sinatra'
  require 'json'
  require 'httpx'
  require 'sequel'

  PATIENT_URL = "http://127.0.0.1:7860"
  DOCTOR_URL = "http://127.0.0.1:7861"
  RM_URL = "http://127.0.0.1:7863"

  module AppointmentService
    class API < Sinatra::Base
      DB = Sequel.connect('sqlite://db/new_appointments.db')
      # # Data appointment dummy
      # APPOINTMENTS = []

      get '/' do
        begin
          patient_response = HTTPX.get("#{PATIENT_URL}/patients")
          doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors")

          content_type :json
          {
            message: "Service janjitemu berjalan dengan baik",
            patient_service_response: JSON.parse(patient_response.body.to_s),
            doctor_service_response: JSON.parse(doctor_response.body.to_s)
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
          # id = APPOINTMENTS.size + 1

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
      
      delete '/appointments/:id' do
        deleted = DB[:appointments].where(id: params['id']).delete
        
        if deleted > 0
            status 204 # No Content response for successful deletion.
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
            
            if patient_response.status == 200 && doctor_response.status == 200
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
                created_at: appointment[:created_at]
              }
            else
              nil
            end
          end.compact
      
          content_type :json
          appointments_for_patient_data.to_json
        end
      end

    end
  end
