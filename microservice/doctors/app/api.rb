require 'sinatra'
require 'sequel'
require 'sqlite3'
require 'json'
require 'time'

module DoctorService
  class API < Sinatra::Base
    DB = Sequel.sqlite("./db/doctors.db")

    get '/' do
      content_type :json
      { message: "Service doctor Berjalan" }.to_json
    end
    post '/doctors' do
      doctor_data = JSON.parse(request.body.read)
      doctor_data['created_at'] = Time.now
      doctor_data['updated_at'] = Time.now

      res = DB[:doctors].insert(doctor_data)
      id = DB[:doctors].max(:id)

      if res
        status 201
        JSON.generate('success' => true, 'doctor_id' => id)
      else
        status 500
        JSON.generate('success' => false, 'error' => res)
      end
    end

    get '/doctors/:id' do
      id = params['id']
      doctor = DB[:doctors].where(id: id).first
      if doctor
        content_type :json
        { id: doctor[:id], name: doctor[:name], specialization: doctor[:specialization] }.to_json
      else
        status 404
        { error: "Doctor not found" }.to_json
      end
    end
  end
end
