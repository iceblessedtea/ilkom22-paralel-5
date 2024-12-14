require 'sinatra'
require 'json'
require 'time'
require 'net/http'
require 'uri'

module MedicalRecordService
  class API < Sinatra::Base
    # Data dummy rekam medis dalam bentuk JSON
    DUMMY_RECORDS = [
      {
        "id" => 1,
        "patient_id" => 1,
        "patient_name" => "John Doe",  # Nama pasien ditambahkan
        "notes" => "Diagnosis: Flu biasa",
        "created_at" => Time.parse("2024-12-14T00:00:00Z"),
        "updated_at" => Time.parse("2024-12-14T00:00:00Z")
      },
      {
        "id" => 2,
        "patient_id" => 2,
        "patient_name" => "Jane Doe",  # Nama pasien ditambahkan
        "notes" => "Diagnosis: Sakit kepala kronis",
        "created_at" => Time.parse("2024-12-14T00:00:00Z"),
        "updated_at" => Time.parse("2024-12-14T00:00:00Z")
      },
      {
        "id" => 3,
        "patient_id" => 3,
        "patient_name" => "Nazwah Ilmi",  # Nama pasien ditambahkan
        "notes" => "Diagnosis: Insomnia",
        "created_at" => Time.parse("2024-12-14T00:00:00Z"),
        "updated_at" => Time.parse("2024-12-14T00:00:00Z")
      }
    ]

    PATIENT_SERVICE_URL = "http://localhost:7860" # URL PatientService

    # Endpoint test service berjalan
    get "/" do
      content_type :json
      { message: "Service rekam medik berjalan" }.to_json
    end

    # Endpoint untuk mendapatkan semua rekam medik
    get '/medical_records' do
      content_type :json
      DUMMY_RECORDS.to_json
    end

    # Endpoint untuk mendapatkan rekam medik berdasarkan ID
    get '/medical_records/:id' do
      id = params['id'].to_i
      record = DUMMY_RECORDS.find { |r| r['id'] == id }

      if record
        # Ambil data pasien dari PatientService
        begin
          uri = URI("#{PATIENT_SERVICE_URL}/patients/#{record['patient_id']}")
          response = Net::HTTP.get_response(uri)

          if response.is_a?(Net::HTTPSuccess)
            patient = JSON.parse(response.body)

            # Gabungkan data rekam medis dengan data pasien
            result = {
              id: record['id'],
              patient_id: record['patient_id'],
              patient_name: record['patient_name'],  # Nama pasien diambil dari rekam medis
              patient_age: patient['age'],
              notes: record['notes'],
              created_at: record['created_at'],
              updated_at: record['updated_at']
            }

            content_type :json
            result.to_json
          else
            status response.code.to_i
            { error: "Pasien dengan ID #{record['patient_id']} tidak ditemukan di PatientService" }.to_json
          end
        rescue StandardError => e
          status 500
          { error: "Gagal mengambil data pasien: #{e.message}" }.to_json
        end
      else
        status 404
        { error: "Rekam medik dengan ID #{id} tidak ditemukan" }.to_json
      end
    end

    # Endpoint untuk menambahkan rekam medik baru
    post '/medical_records' do
      begin
        record_data = JSON.parse(request.body.read)
        record_data['created_at'] = Time.now
        record_data['updated_at'] = Time.now

        record_id = DUMMY_RECORDS.size + 1
        record_data['id'] = record_id

        DUMMY_RECORDS << record_data

        status 201
        { success: true, record_id: record_id }.to_json
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      end
    end
  end
end
