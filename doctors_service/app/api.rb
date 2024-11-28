require 'sinatra'
require 'sinatra/cross_origin'
require 'sequel'
require 'sqlite3'
require 'json'
require 'time'
require 'faye/websocket'
require 'thread'

module DoctorService
  class API < Sinatra::Base
    configure do
      enable :cross_origin
      set :allow_methods, [:get, :post, :put, :delete, :options]
      set :public_folder, File.dirname(__FILE__) + '/public' # Menentukan folder publik
    end

    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

    # Connect ke database SQLite
    db = Sequel.sqlite("./db/healthcare.db")

    # Tabel Dokter
    doctors = db[:doctors]

    # WebSocket setup
    connections = []

    get '/ws' do
      request.websocket do |ws|
        ws.onopen { connections << ws }
        ws.onclose { connections.delete(ws) }
      end
    end
    
    def broadcast(connections, message)
      connections.each do |ws|
        ws.send(message) if ws.open?
      end
    end
    # CORS preflight request
    options "*" do
      response.headers["Allow"] = "GET, POST, PUT, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Content-Type"
      200
    end

    # Route untuk mengakses halaman utama 
    get '/' do
      send_file File.join(settings.public_folder, 'index.html') 
    end
    
    # Create 
    post '/doctors' do
      doctor_param = JSON.parse(request.body.read)
      doctor_param['created_at'] = Time.now
      doctor_param['updated_at'] = Time.now

      max_id = doctors.max(:id) || 0  
      doctor_param['id'] = max_id + 1 

      res = doctors.insert(doctor_param)
      id = doctors.max(:id)

      if res 
        new_doctor = doctors.where(id: id).first
        broadcast(connections, { action: 'create', data: new_doctor }.to_json)
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
        updated_doctor = doctors.where(id: params['id']).first
        broadcast(connections, { action: 'update', data: updated_doctor }.to_json)
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
        broadcast(connections, { action: 'delete', data: { id: params['id'] } }.to_json)
        status 200
        JSON.generate('success'=>true)
      else
        status 500
        JSON.generate('success'=>false)
      end
    end
  end
end
