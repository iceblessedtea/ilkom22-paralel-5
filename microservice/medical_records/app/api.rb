require 'sinatra' 
require 'sequel'
require 'sqlite3'
require 'json'
require 'time'

module MedicalRecordService
  class API < Sinatra::Base
    # Inisialisasi database SQLite
    DB = Sequel.sqlite("./db/medical_records.db")

    # Mengambil data dari tabel pasien
    def fetch_patient(patient_id)
      DB[:patients].where(id: patient_id).first
    end

    get "/" do
      content_type :json
      { message: "Service rekam medik Berjalan" }.to_json
    end 

    # Route untuk menampilkan semua medical records
    get '/medical_records' do
      records = DB[:medical_records].all
      records.map! do |record|
        patient = fetch_patient(record[:patient_id])
        {
          id: record[:id],
          patient_id: record[:patient_id],
          patient_name: patient[:name],
          notes: record[:notes],
          created_at: record[:created_at],
          updated_at: record[:updated_at]
        }
      end
      content_type :json
      records.to_json
    end

    # Route untuk menampilkan medical record berdasarkan ID
    get '/medical_records/:id' do
      id = params['id'].to_i
      record = DB[:medical_records].where(id: id).first
      if record
        patient = fetch_patient(record[:patient_id])
        content_type :json
        {
          id: record[:id],
          patient_id: record[:patient_id],
          patient_name: patient[:name],
          notes: record[:notes],
          created_at: record[:created_at],
          updated_at: record[:updated_at]
        }.to_json
      else
        status 404
        { error: "Rekam medik dengan ID #{id} tidak ditemukan" }.to_json
      end
    end

    # Route untuk menambahkan medical record
    post '/medical_records' do
      record_data = JSON.parse(request.body.read)
      record_data['created_at'] = Time.now
      record_data['updated_at'] = Time.now

      # Save to database
      DB[:medical_records].insert(record_data)
      record_id = DB[:medical_records].max(:id)

      status 201
      { success: true, record_id: record_id }.to_json
    end

    # Route untuk mengedit medical record berdasarkan ID
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

    # Route untuk menghapus medical record berdasarkan ID
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
  end
end
