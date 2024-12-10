require 'sinatra'
require 'sinatra/cross_origin'
require 'sinatra/json'
require 'json'
require 'time'
require 'sequel'
require 'sqlite3'
require 'net/http'
require 'uri'
require 'logger'
require_relative 'models/patient'
require_relative 'models/appointment'

# Configure logging
$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

set :port, 5678

module JanjiTemu
  class API < Sinatra::Base
    configure do
      enable :cross_origin
      enable :method_override
      enable :logging
      set :allow_methods, [:get, :post, :put, :delete, :options]
      set :views, File.join(File.dirname(__FILE__), '../app/views')
      set :show_exceptions, :after_handler
    end

    # Global Error Handler
    error do
      content_type :json
      error = env['sinatra.error']
      
      $logger.error "Unhandled Error: #{error.class} - #{error.message}"
      $logger.error error.backtrace.join("\n")

      status 500
      {
        error: 'Internal Server Error',
        message: error.message
      }.to_json
    end

    # Not Found Handler
    not_found do
      content_type :json
      status 404
      {
        error: 'Not Found',
        message: 'The requested resource could not be found'
      }.to_json
    end

    # Logging Middleware
    before do
      $logger.info "Request: #{request.request_method} #{request.path}"
      $logger.info "Params: #{params}"
      
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

    helpers do
      def current_patient
        # Mock current patient - dalam implementasi nyata ini akan diambil dari session
        Patient.first
      rescue => e
        $logger.error "Error fetching current patient: #{e.message}"
        nil
      end

      def fetch_doctors
        uri = URI("#{http://localhost:9091/doctors}/doctors")
      
        begin
          response = Net::HTTP.get(uri)
          doctors = JSON.parse(response)
      
          # Transform external doctor data
          doctors.map do |doctor|
            {
              id: doctor['id'],
              name: doctor['name'],
              specialization: doctor['specialization'],
              years_of_experience: calculate_years_of_experience(doctor['work_since']),
              working_since: doctor['work_since']
            }
          end
        rescue SocketError, Errno::ECONNREFUSED => e
          $logger.error "Doctor service connection error: #{e.message}"
          # Fallback to an empty array if the service is unavailable
          []
        rescue JSON::ParserError => e
          $logger.error "Error parsing doctor data: #{e.message}"
          # Fallback to an empty array if the response cannot be parsed
          []
        rescue => e
          $logger.error "Unexpected error fetching doctors: #{e.message}"
          # Fallback to an empty array for any other unexpected errors
          []
        end
      end

      def calculate_years_of_experience(work_since)
        current_year = Time.now.year
        current_year - work_since
      rescue => e
        $logger.error "Error calculating years of experience: #{e.message}"
        0
      end
    end

    # Route untuk menampilkan semua janji temu dalam JSON
    get '/appointments' do
      content_type :json
      begin
        appointments = Appointment.all.map do |appointment|
          {
            id: appointment.id,
            patient: appointment.patient&.name || 'Unknown',
            doctor: appointment.doctor&.name || 'Unknown',
            date: appointment.date,
            time: appointment.time,
            description: appointment.description
          }
        end
        json appointments
      rescue Sequel::DatabaseError => e
        $logger.error "Database error fetching appointments: #{e.message}"
        status 500
        json({ 
          error: 'Database Error', 
          message: 'Could not retrieve appointments' 
        })
      rescue => e
        $logger.error "Unexpected error fetching appointments: #{e.message}"
        status 500
        json({ 
          error: 'Fetch Error', 
          message: 'Could not fetch appointments' 
        })
      end
    end

    # Route untuk menampilkan semua dokter dalam JSON
    get '/doctors' do
      content_type :json
      begin
        doctors = fetch_doctors
        
        if doctors.empty?
          $logger.warn "No doctors found"
          status 404
          return json({ 
            error: 'Not Found', 
            message: 'No doctors available' 
          })
        end
        
        json doctors
      rescue => e
        $logger.error "Error in doctors route: #{e.message}"
        status 500
        json({ 
          error: 'Fetch Error', 
          message: 'Could not retrieve doctors' 
        })
      end
    end

    # Route untuk membuat janji temu baru
    post '/appointments' do
      begin
        # Parse input data
        data = if params['patient_id']
          params
        else
          JSON.parse(request.body.read.to_s)
        end

        # Validate required fields
        required_fields = ['patient_id', 'doctor_id', 'date', 'time', 'description']
        missing_fields = required_fields.select { |field| data[field].nil? || data[field].to_s.empty? }
        
        unless missing_fields.empty?
          $logger.warn "Appointment creation failed: Missing fields #{missing_fields}"
          halt 400, json({ 
            error: 'Validation Error', 
            message: 'Missing required fields', 
            missing_fields: missing_fields 
          })
        end

        # Validate patient
        patient = Patient.where(id: data['patient_id']).first
        unless patient
          $logger.warn "Appointment creation failed: Invalid patient ID"
          halt 400, json({ 
            error: 'Validation Error', 
            message: 'Invalid patient ID' 
          })
        end

        # Validate doctor
        doctor_exists = fetch_doctors.any? { |doc| doc[:id] == data['doctor_id'].to_i }
        unless doctor_exists
          $logger.warn "Appointment creation failed: Invalid doctor ID"
          halt 400, json({ 
            error: 'Validation Error', 
            message: 'Invalid doctor ID' 
          })
        end

        # Create appointment
        appointment = Appointment.create(
          patient_id: data['patient_id'],
          doctor_id: data['doctor_id'],
          date: data['date'],
          time: data['time'],
          description: data['description']
        )
        
        $logger.info "Appointment created successfully: ID #{appointment.id}"
        
        if request.content_type == 'application/json'
          status 201
          json appointment
        else
          redirect_path = case params[:redirect_to]
          when '/patient-appointments-view'
            '/appointments-viewpasien'
          else
            '/appointments-view'
          end
          redirect redirect_path
        end
      rescue Sequel::ValidationError => e
        $logger.error "Validation error creating appointment: #{e.message}"
        status 422
        json({ 
          error: 'Validation Failed', 
          message: e.message 
        })
      rescue JSON::ParserError => e
        $logger.error "JSON parsing error: #{e.message}"
        status 400
        json({ 
          error: 'Invalid JSON', 
          message: e.message 
        })
      rescue => e
        $logger.error "Unexpected error creating appointment: #{e.message}"
        status 500
        json({ 
          error: 'Could not create appointment', 
          message: e.message 
        })
      end
    end

    # Route untuk mengupdate appointment
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
    
    # Route untuk menampilkan view dari pasien
    get '/appointments-view' do
      content_type :html
      @appointments = Appointment.all
      @patients = Patient.all
      @doctors = fetch_doctors
      erb :appointments_index
    end
    
# Route untuk menampilkan halaman new appointment
    get '/appointments/new' do
      content_type :html
      @patients = Patient.all
      @doctors = Doctor.all
      @selected_patient_id = params[:patient_id]
      @redirect_to = params[:redirect_to]
      erb :new_appointment
    end

    # Route untuk menampilkan view appointment dari pasien
    get '/appointments-viewpasien' do
      content_type :html
      @appointments = Appointment.where(patient_id: current_patient.id)
      @patients = Patient.all
      @doctors = Doctor.all
      erb :pasien_appointments_view
    end

    #Route ke alnding page
    get '/LandingPage' do
      content_type :html
      erb :landing_Page
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