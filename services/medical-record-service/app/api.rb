require 'sinatra'
require 'sequel'
require 'json'
require 'time'
require 'net/http'
require 'uri'

module MedicalRecordService
  class API < Sinatra::Base
    DB = Sequel.connect(ENV.fetch('DATABASE_URL', 'postgres://healthcare:healthcare@localhost:5432/medical_record_service'))
    
    # Endpoint ke service pasien
    PATIENT_URL = ENV.fetch('PATIENT_URL', 'http://localhost:7860')

    # Mengambil data dari tabel pasien
    def fetch_patient(patient_id)
      uri = URI("#{PATIENT_URL}/patients/#{patient_id}")
      response = Net::HTTP.get_response(uri)
      if response.is_a?(Net::HTTPSuccess)
        patient_payload = JSON.parse(response.body)
        patient_payload['patient'] || patient_payload
      else
        nil
      end
    end

    get "/" do
      content_type :json
      { message: "Service rekam medik berjalan" }.to_json
    end 

    get "/health" do
      content_type :json
      { status: 'ok', service: 'medical-record-service' }.to_json
    end

    get '/medical-records' do
      call env.merge('PATH_INFO' => '/medical_records')
    end

    # Route untuk menampilkan semua rekam medis
    get '/medical_records' do
      records = DB[:medical_records].all
      records.map! do |record|
        patient = fetch_patient(record[:patient_id])
        {
          id: record[:id],
          patient_id: record[:patient_id],
          patient_name: patient ? patient['name'] : nil,
          diagnosis: record[:diagnosis],
          created_at: record[:created_at],
          updated_at: record[:updated_at]
        }
      end
      content_type :json
      records.to_json
    end

    # Route untuk menampilkan rekam medis berdasarkan ID
    get '/medical_records/:id' do
      id = params['id'].to_i
      record = DB[:medical_records].where(id: id).first
      if record
        patient = fetch_patient(record[:patient_id])
        content_type :json
        {
          id: record[:id],
          patient_id: record[:patient_id],
          patient_name: patient ? patient['name'] : nil,
          diagnosis: record[:diagnosis],
          created_at: record[:created_at],
          updated_at: record[:updated_at]
        }.to_json
      else
        status 404
        { error: "Rekam medik dengan ID #{id} tidak ditemukan" }.to_json
      end
    end

    get '/medical-records/:id' do
      call env.merge('PATH_INFO' => "/medical_records/#{params['id']}")
    end

    # Route untuk menambahkan banyak rekam medis sekaligus
    post '/medical_records' do
      begin
        records_data = JSON.parse(request.body.read)
        
        # Validasi apakah data yang dikirimkan berbentuk array
        if !records_data.is_a?(Array) || records_data.empty?
          status 400
          return { error: "Data harus berupa array dan tidak boleh kosong." }.to_json
        end

        # Menambahkan setiap rekam medis ke database
        inserted_ids = []
        records_data.each do |record|
          # Validasi bahwa field 'patient_id' dan 'diagnosis' ada
          if record['patient_id'].nil? || record['diagnosis'].nil?
            status 400
            return { error: "Setiap record harus memiliki patient_id dan diagnosis." }.to_json
          end

          # Pastikan bahwa patient_id valid dengan mengecek ke service pasien
          patient = fetch_patient(record['patient_id'])
          if patient.nil?
            status 404
            return { error: "Patient dengan ID #{record['patient_id']} tidak ditemukan" }.to_json
          end

          record['created_at'] = Time.now
          record['updated_at'] = Time.now

          # Simpan rekam medis ke database
          inserted_id = DB[:medical_records].insert(record)
          inserted_ids << inserted_id
        end

        status 201
        { success: true, inserted_ids: inserted_ids }.to_json
      rescue JSON::ParserError => e
        status 400
        { error: "Payload JSON tidak valid: #{e.message}" }.to_json
      rescue StandardError => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    post '/medical-records' do
      call env.merge('PATH_INFO' => '/medical_records')
    end

    # Route untuk mengedit rekam medis berdasarkan ID
    put '/medical_records/:id' do
      id = params['id'].to_i
      record_data = JSON.parse(request.body.read)
      record_data['updated_at'] = Time.now

      record = DB[:medical_records].where(id: id).first
      if record
        DB[:medical_records].where(id: id).update(record_data)
        content_type :json
        { success: true, record_id: id }.to_json
      else
        status 404
        { error: "Rekam medik dengan ID #{id} tidak ditemukan" }.to_json
      end
    end

    put '/medical-records/:id' do
      call env.merge('PATH_INFO' => "/medical_records/#{params['id']}")
    end

    # Route untuk menghapus rekam medis berdasarkan ID
    delete '/medical_records/:id' do
      id = params['id'].to_i
      record = DB[:medical_records].where(id: id).first
      if record
        DB[:medical_records].where(id: id).delete
        status 200
        { success: true, message: "Rekam medik dengan ID #{id} berhasil dihapus" }.to_json
      else
        status 404
        { error: "Rekam medik dengan ID #{id} tidak ditemukan" }.to_json
      end
    end

    delete '/medical-records/:id' do
      call env.merge('PATH_INFO' => "/medical_records/#{params['id']}")
    end
  end
end
