require 'sinatra'
require 'sequel'
require 'sqlite3'
require 'json'
require 'time'
require 'net/http'

MEDICAL_RECORD_URL = ENV['MEDICAL_RECORD_URL'] || "http://127.0.0.1:7863"

module PatientService
  class API < Sinatra::Base
    # Inisialisasi database
    DB = Sequel.sqlite("./db/patients.db")

    # Endpoint untuk mengecek status service
    get "/" do
      uri_medical_record = URI(MEDICAL_RECORD_URL)

      begin
        # Ambil data dari service MedicalRecord
        response = Net::HTTP.get_response(uri_medical_record)

        if response.is_a?(Net::HTTPSuccess)
          medical_record_response = JSON.parse(response.body)

          content_type :json
          {
            message: "Service pasien berjalan dengan baik",
            medical_record_service_response: medical_record_response
          }.to_json
        else
          status 500
          { error: "Service medical record tidak merespon dengan baik. Status: #{response.code}" }.to_json
        end
      rescue SocketError => e
        status 500
        { error: "Gagal terhubung ke service medical record: #{e.message}" }.to_json
      rescue JSON::ParserError => e
        status 500
        { error: "Respon dari service medical record tidak valid: #{e.message}" }.to_json
      end
    end

    # Endpoint untuk membuat data pasien baru
    post '/patients' do
      begin
        # Parsing data pasien dari request
        patient_data = JSON.parse(request.body.read)
        patient_data['created_at'] = Time.now
        patient_data['updated_at'] = Time.now

        # Simpan data ke database
        res = DB[:patients].insert(patient_data)
        id = DB[:patients].max(:id)

        if res
          status 201
          JSON.generate('success' => true, 'patient_id' => id)
        else
          status 500
          JSON.generate('success' => false, 'error' => 'Gagal menyimpan data pasien')
        end
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    # Endpoint untuk mengambil data pasien berdasarkan ID
    get '/patients/:id' do
      id = params['id']

      # Ambil data pasien dari database
      patient = DB[:patients].where(id: id).first
      if patient
        content_type :json
        {
          id: patient[:id],
          name: patient[:name],
          age: patient[:age],
          created_at: patient[:created_at],
          updated_at: patient[:updated_at]
        }.to_json
      else
        status 404
        { error: "Patient dengan ID #{id} tidak ditemukan" }.to_json
      end
    end
  end
end
