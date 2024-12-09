require 'sinatra'
require 'sequel'
require 'sqlite3'
require 'json'
require 'time'

module MedicalRecordService
  class API < Sinatra::Base
    DB = Sequel.sqlite("./db/medical_records.db")

    get "/" do
      content_type :json
      { message: "Service rekam medik Berjalan" }.to_json
    end 
    
    post '/medical_records' do
      record_data = JSON.parse(request.body.read)
      record_data['created_at'] = Time.now
      record_data['updated_at'] = Time.now

      res = DB[:medical_records].insert(record_data)
      id = DB[:medical_records].max(:id)

      if res
        status 201
        JSON.generate('success' => true, 'record_id' => id)
      else
        status 500
        JSON.generate('success' => false, 'error' => res)
      end
    end

    get '/medical_records/:id' do
      id = params['id']
      record = DB[:medical_records].where(id: id).first
      if record
        content_type :json
        { id: record[:id], patient_id: record[:patient_id], notes: record[:notes] }.to_json
      else
        status 404
        { error: "Medical record not found" }.to_json
      end
    end
  end
end
