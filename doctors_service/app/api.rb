require 'sinatra'
require 'sinatra/cross_origin'
require 'sequel'
require 'sqlite3'
require 'json'
require 'time'

module DoctorService
  class API < Sinatra::Base
    configure do
      enable :cross_origin
      set :allow_methods, [:get, :post, :put, :delete, :options]
      set :public_folder, File.dirname(__FILE__) + '/views' # Menentukan folder publik
    end

    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

    # Connect ke database SQLite
    db = Sequel.sqlite("./db/healthcare.db")

    # Tabel Dokter
    doctors = db[:doctors]

    # CORS preflight request
    options "*" do
      response.headers["Allow"] = "GET, POST, PUT, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Content-Type"
      200
    end

    # Route untuk mengakses halaman utama (index.html)
    get '/' do
      send_file File.join(settings.public_folder, 'index.html') # Mengirim file HTML
    end
    
    # Create 
    post '/doctors' do
      doctor_param = JSON.parse(request.body.read)
      doctor_param['created_at'] = Time.now
      doctor_param['updated_at'] = Time.now

      res = doctors.insert(doctor_param)
      id = doctors.max(:id)

      if res 
        status 201
        JSON.generate('success'=>true, 'doctor_id' => id)
      else
        status 500
        JSON.generate('success'=>false)
      end
    end

    # Read all 
    get '/doctors' do
      content_type :json
      doctors.all.to_json
    end

    # Read by ID 
    get '/doctors/:id' do
      doctor = doctors.where(id: params['id']).first
      if doctor
        content_type :json
        {id: doctor[:id], name: doctor[:name], specialization: doctor[:specialization], phone: doctor[:phone], work_since: doctor[:work_since], created_at: doctor[:created_at], updated_at: doctor[:updated_at]}.to_json
      else
        status 404
        {error: "Doctor not found"}.to_json
      end
    end

    # Update 
    put '/doctors/:id' do
      doctor_param = JSON.parse(request.body.read)
      doctor_param['updated_at'] = Time.now

      res = doctors.where(id: params['id']).update(doctor_param)

      if res
        status 200
        JSON.generate('success'=>true)
      else
        status 500
        JSON.generate('success'=>false)
      end
    end

    # Delete 
    delete '/doctors/:id' do
      res = doctors.where(id: params['id']).delete

      if res
        status 200
        JSON.generate('success'=>true)
      else
        status 500
        JSON.generate('success'=>false)
      end
    end
  end
end
