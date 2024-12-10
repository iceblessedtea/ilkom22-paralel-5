require 'sinatra'
require 'json'
require 'httpx'

PATIENT_URL = "http://127.0.0.1:7860"
DOCTOR_URL = "http://127.0.0.1:7861"

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
  end
end
