require 'sinatra'
require 'json'
require 'time'
require 'net/http'
require 'uri'

module PatientService
  class API < Sinatra::Base
    # Data pasien dummy
    PATIENTS = [
      { id: 1, name: "John Doe", age: 30, created_at: Time.now, updated_at: Time.now },
      { id: 2, name: "Jane Doe", age: 25, created_at: Time.now, updated_at: Time.now },
      { id: 3, name: "Nazwah ilmi", age: 21, created_at: Time.now, updated_at: Time.now },
    ]

    REKAM_MEDIK_SERVICE_URL = "http://localhost:7863" # URL Service Rekam Medik

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
      rescue StandardError => e
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

    # Endpoint untuk melihat pasien dengan rekam medisnya
    get '/patients/:id/records' do
      patient = PATIENTS.find { |p| p[:id] == params['id'].to_i }

      if patient
        # Fetch rekam medik dari Service Rekam Medik
        uri = URI("#{REKAM_MEDIK_SERVICE_URL}/medical_records/#{patient[:id]}")
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          medical_record = JSON.parse(response.body)

          # Gabungkan data pasien dengan data rekam medik
          result = {
            id: patient[:id],
            name: patient[:name],
            age: patient[:age],
            medical_record: medical_record
          }

          content_type :json
          result.to_json
        else
          status response.code.to_i
          { error: "Gagal mengambil data rekam medik untuk pasien ID #{patient[:id]}" }.to_json
        end
      else
        status 404
        { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end
  end
end
