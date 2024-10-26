require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/json'
require 'json'
require 'time'
require 'sequel'
require 'sqlite3'
require_relative 'models/patient'
require_relative 'models/doctor'
require_relative 'models/appointment'

module JanjiTemu
  class API < Sinatra::Base
    configure do
      enable :cross_origin
      enable :method_override  # Enable method override
      set :allow_methods, [:get, :post, :put, :delete, :options]
      set :views, File.join(File.dirname(__FILE__), '../app/views')
      set :show_exceptions, false
    end

    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

    # Route untuk menampilkan semua janji temu dalam JSON
    get '/appointments' do
      content_type :json
      appointments = Appointment.all.map do |appointment|
        {
          id: appointment.id,
          patient: appointment.patient.name,
          doctor: appointment.doctor.name,
          date: appointment.date,
          time: appointment.time,
          description: appointment.description
        }
      end
      json appointments
    end

    # Route untuk membuat janji temu baru
    post '/appointments' do
      begin
        data = if params['patient_id']
          params
        else
          JSON.parse(request.body.read.to_s)
        end

        required_fields = ['patient_id', 'doctor_id', 'date', 'time', 'description']
        missing_fields = required_fields.select { |field| data[field].nil? || data[field].to_s.empty? }
        
        unless missing_fields.empty?
          halt 400, json({ 
            error: 'Missing required fields', 
            missing_fields: missing_fields 
          })
        end

        appointment = Appointment.create(
          patient_id: data['patient_id'],
          doctor_id: data['doctor_id'],
          date: data['date'],
          time: data['time'],
          description: data['description']
        )
        
        if request.content_type == 'application/json'
          status 201
          json appointment
        else
          redirect '/appointments-view'
        end
      rescue JSON::ParserError => e
        halt 400, json({ error: 'Invalid JSON format', message: e.message })
      rescue => e
        halt 422, json({ error: 'Could not create appointment', message: e.message })
      end
    end

    # Route untuk mengupdate appointment
    # Menggunakan POST dengan _method=put untuk form submission
    post '/appointments/:id' do
      begin
        appointment = Appointment[params[:id]]
        halt 404, "Appointment not found" unless appointment

        appointment.update(
          patient_id: params['patient_id'],
          doctor_id: params['doctor_id'],
          date: params['date'],
          time: params['time'],
          description: params['description']
        )

        redirect '/appointments-view'
      rescue => e
        halt 422, "Could not update appointment: #{e.message}"
      end
    end

    # Route untuk API PUT request
    put '/appointments/:id' do
      content_type :json
      begin
        appointment = Appointment[params[:id]]
        halt 404, json({ error: 'Appointment not found' }) unless appointment

        data = JSON.parse(request.body.read.to_s)
        
        appointment.update(
          patient_id: data['patient_id'],
          doctor_id: data['doctor_id'],
          date: data['date'],
          time: data['time'],
          description: data['description']
        )

        json appointment
      rescue => e
        halt 422, json({ error: 'Could not update appointment', message: e.message })
      end
    end

    # Route untuk delete appointment via form
    post '/appointments/:id/delete' do
      begin
        appointment = Appointment[params[:id]]
        halt 404, "Appointment not found" unless appointment
        
        appointment.delete
        
        redirect '/appointments-view'
      rescue => e
        halt 422, "Could not delete appointment: #{e.message}"
      end
    end

    # Route untuk delete appointment via API
    delete '/appointments/:id' do
      content_type :json
      begin
        appointment = Appointment[params[:id]]
        halt 404, json({ error: 'Appointment not found' }) unless appointment
        
        appointment.delete
        
        json({ success: true })
      rescue => e
        halt 422, json({ error: 'Could not delete appointment', message: e.message })
      end
    end

    # Route untuk menampilkan form edit
    get '/appointments/:id/edit' do
      content_type :html
      @appointment = Appointment[params[:id]]
      halt 404, "Appointment not found" unless @appointment
      @patients = Patient.all
      @doctors = Doctor.all
      erb :edit_appointment
    end

    get '/appointments-view' do
      content_type :html
      @appointments = Appointment.all
      @patients = Patient.all
      @doctors = Doctor.all
      erb :appointments_index
    end

    get '/appointments/new' do
      content_type :html
      @patients = Patient.all
      @doctors = Doctor.all
      erb :new_appointment
    end

    options '*' do
      response.headers['Allow'] = 'GET, POST, PUT, DELETE, OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'Authorization, Content-Type, Accept'
      response.headers['Access-Control-Allow-Origin'] = '*'
      200
    end

    get '/' do
      redirect '/appointments-view'
    end
  end
end