require 'sinatra'
require 'json'
require 'time'

module PatientService
  class API < Sinatra::Base
    # Data pasien dummy
    PATIENTS = [
      { id: 1, name: "John Doe", age: 30, created_at: Time.now, updated_at: Time.now },
      { id: 2, name: "Jane Doe", age: 25, created_at: Time.now, updated_at: Time.now }
    ]

    get "/" do
      content_type :json
      { message: "Service pasien berjalan dengan baik", patients: PATIENTS }.to_json
    end

    post '/patients' do
      begin
        patient_data = JSON.parse(request.body.read)
        id = PATIENTS.size + 1

        new_patient = {
          id: id,
          name: patient_data["name"],
          age: patient_data["age"],
          created_at: Time.now,
          updated_at: Time.now
        }

        PATIENTS << new_patient

        status 201
        { success: true, patient_id: id }.to_json
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    get '/patients/:id' do
      patient = PATIENTS.find { |p| p[:id] == params['id'].to_i }

      if patient
        content_type :json
        patient.to_json
      else
        status 404
        { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end
  end
end
