  require 'sinatra'
  require 'json'
  require 'httpx'

  PATIENT_URL = "http://127.0.0.1:7860"
  DOCTOR_URL = "http://127.0.0.1:7861"
  RM_URL = "http://127.0.0.1:7863"

  module AppointmentService
    class API < Sinatra::Base
      # Data appointment dummy
      APPOINTMENTS = []

      get '/' do
        begin
          patient_response = HTTPX.get("#{PATIENT_URL}/")
          doctor_response = HTTPX.get("#{DOCTOR_URL}/")

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
          id = APPOINTMENTS.size + 1

          new_appointment = {
            id: id,
            patient_id: appointment_data["patient_id"],
            doctor_id: appointment_data["doctor_id"],
            date: appointment_data["date"],
            created_at: Time.now,
            updated_at: Time.now
          }

          APPOINTMENTS << new_appointment

          status 201
          { success: true, appointment_id: id }.to_json
        rescue JSON::ParserError => e
          status 400
          { error: "Invalid JSON payload: #{e.message}" }.to_json
        rescue => e
          status 500
          { error: "Error processing request: #{e.message}" }.to_json
        end
      end

      get '/appointments' do
        if APPOINTMENTS.empty?
          status 404
          { error: "No appointments found" }.to_json
        else
          appointments_data = APPOINTMENTS.map do |appointment|
            # Ambil data pasien dan dokter berdasarkan appointment
            patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
            doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")
      
            if patient_response.status == 200 && doctor_response.status == 200
              patient_data = JSON.parse(patient_response.body.to_s)
              doctor_data = JSON.parse(doctor_response.body.to_s)
      
              {
                appointment_id: appointment[:id],
                patient_id: appointment[:patient_id],
                patient_name: patient_data["name"],
                doctor_id: appointment[:doctor_id],
                doctor_name: doctor_data["name"],  # Sesuaikan dengan nama dokter yang valid
                date: appointment[:date],
                created_at: appointment[:created_at]
              }
            else
              nil
            end
          end.compact
      
          content_type :json
          appointments_data.to_json
        end
      end
      

      get '/appointments/:id' do
        appointment = APPOINTMENTS.find { |a| a[:id] == params['id'].to_i }

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
        appointments_for_doctor = APPOINTMENTS.select { |appointment| appointment[:doctor_id] == doctor_id }

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
              {
                appointment_id: appointment[:id],
                patient_id: appointment[:patient_id],
                patient_name: patient_data["name"],
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
        appointments_for_patient = APPOINTMENTS.select { |appointment| appointment[:patient_id] == patient_id }
      
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
              
              {
                appointment_id: appointment[:id],
                patient_id: appointment[:patient_id],
                patient_name: patient_data["name"],
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
