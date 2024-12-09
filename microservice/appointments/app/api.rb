require 'sinatra'
require 'sequel'
require 'sqlite3'
require 'json'
require 'time'
require 'net/http'
require 'httpx'

PATIENT_URL = ENV['PATIENT_URL'] || "http://127.0.0.1:7860"
DOCTOR_URL = ENV['DOCTOR_URL'] || "http://127.0.0.1:7861"

module AppointmentService
  class API < Sinatra::Base
    DB = Sequel.sqlite("./db/appointments.db")

    get '/' do
      uri_patient = URI("http://localhost:7860/")
      uri_doctor = URI("http://localhost:7861/")

      begin
        patient_response = Net::HTTP.get(uri_patient)
        doctor_response = Net::HTTP.get(uri_doctor)

        content_type :json
        {
          message: "Service janjitemu berjalan dengan baik",
          patient_service_response: JSON.parse(patient_response),
          doctor_service_response: JSON.parse(doctor_response)
        }.to_json
      rescue => e
        status 500
        { error: "Error communicating with other services: #{e.message}" }.to_json
      end
    end

    post '/appointments' do
      begin
        appointment_data = JSON.parse(request.body.read)
        appointment_data['created_at'] = Time.now
        appointment_data['updated_at'] = Time.now

        res = DB[:appointments].insert(appointment_data)
        id = DB[:appointments].max(:id)

        if res
          status 201
          JSON.generate('success' => true, 'appointment_id' => id)
        else
          status 500
          JSON.generate('success' => false, 'error' => 'Failed to save appointment')
        end
      rescue => e
        status 500
        { error: "Error processing request: #{e.message}" }.to_json
      end
    end

    get '/appointments/:id' do
      id = params['id']
      appointment = DB[:appointments].where(id: id).first

      if appointment
        begin
          patient_response = HTTPX.get("#{PATIENT_URL}/patients/#{appointment[:patient_id]}")
          doctor_response = HTTPX.get("#{DOCTOR_URL}/doctors/#{appointment[:doctor_id]}")

          # Cek status respon
          if patient_response.status != 200 || doctor_response.status != 200
            status 500
            return { error: "Failed to fetch patient or doctor data" }.to_json
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
