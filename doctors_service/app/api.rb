require 'sinatra'
require 'sinatra/cross_origin'
require 'sequel'
require 'sqlite3'
require 'json'
require 'time'

# Memuat model
require_relative 'models/doctor'
require_relative 'models/room'
require_relative 'models/schedule'
require_relative 'models/timeslot'

module DoctorService
  class API < Sinatra::Base
    configure do
      enable :cross_origin
      enable :method_override
      set :allow_methods, [:get, :post, :put, :delete, :options]
      set :public_folder, File.dirname(__FILE__) + '/public'
    end

    before do
      response.headers['Access-Control-Allow-Origin'] = '*'
    end

    # CORS preflight request
    options "*" do
      response.headers["Allow"] = "GET, POST, PUT, DELETE, OPTIONS"
      response.headers["Access-Control-Allow-Headers"] = "Content-Type"
      200
    end

    # Helper method untuk response format
    def respond_with(data, format: :html)
      if format == :json
        content_type :json
        data.to_json
      else
        content_type :html
        erb :response, locals: { data: data }
      end
    end

    # Route untuk halaman utama
    get '/' do
      format = request.accept.first.to_sym
    
      if format == :json
        content_type :json
        { message: 'Welcome to the Doctor Service API' }.to_json
      else
        erb :welcome
      end
    end

    # ========== DOCTOR ROUTES ==========

    # Tampilkan semua dokter
    get '/doctors' do
      format = request.accept.first.to_sym
      @doctors = Doctor.all

      if format == :json
        respond_with(@doctors, format: :json)
      else
        erb :doctors
      end
    end

    # Form tambah dokter
    get '/doctors/new' do
      erb :new_doctor
    end

    # Tambah dokter
    post '/doctors' do
      doctor = Doctor.new(
        name: params[:name],
        specialization: params[:specialization],
        phone: params[:phone],
        work_since: params[:work_since]
      )

      if doctor.save
        redirect '/doctors'
      else
        halt 400, erb(:error, locals: { message: "Gagal menambahkan dokter: #{doctor.errors.full_messages.join(', ')}" })
      end
    end

    # Form edit dokter
    get '/doctors/:id/edit' do
      @doctor = Doctor[params[:id]]
      halt 404, erb(:error, locals: { message: "Dokter tidak ditemukan." }) unless @doctor

      erb :edit_doctor
    end

    # Edit dokter
    put '/doctors/:id' do
      doctor = Doctor[params[:id]]
      halt 404, erb(:error, locals: { message: "Dokter tidak ditemukan." }) unless doctor

      if doctor.update(
        name: params[:name],
        specialization: params[:specialization],
        phone: params[:phone],
        work_since: params[:work_since]
      )
        redirect '/doctors'
      else
        halt 400, erb(:error, locals: { message: "Gagal mengupdate dokter: #{doctor.errors.full_messages.join(', ')}" })
      end
    end

    # Hapus dokter
    delete '/doctors/:id' do
      doctor = Doctor[params[:id]]
      halt 404, erb(:error, locals: { message: "Dokter tidak ditemukan." }) unless doctor

      if doctor.destroy
        redirect '/doctors'
      else
        halt 500, erb(:error, locals: { message: "Gagal menghapus dokter." })
      end
    end

    # ========== ROOM ROUTES ==========

    # Tampilkan semua ruang
    get '/rooms' do
      format = request.accept.first.to_sym
      @rooms = Room.all

      if format == :json
        respond_with(@rooms, format: :json)
      else
        erb :rooms
      end
    end

    # Form tambah ruang
    get '/rooms/new' do
      erb :new_room
    end

    # Tambah ruang
    post '/rooms' do
      room = Room.new(name: params[:name])
      if room.save
        redirect '/rooms'
      else
        halt 400, erb(:error, locals: { message: "Gagal menambahkan ruang: #{room.errors.full_messages.join(', ')}" })
      end
    end

    # Form edit ruang
    get '/rooms/:id/edit' do
      @room = Room[params[:id]]
      halt 404, erb(:error, locals: { message: "Ruang tidak ditemukan." }) unless @room

      erb :edit_room
    end

    # Edit ruang
    put '/rooms/:id' do
      room = Room[params[:id]]
      halt 404, erb(:error, locals: { message: "Ruang tidak ditemukan." }) unless room

      if room.update(name: params[:name])
        redirect '/rooms'
      else
        halt 400, erb(:error, locals: { message: "Gagal mengupdate ruang: #{room.errors.full_messages.join(', ')}" })
      end
    end

    # Hapus ruang
    delete '/rooms/:id' do
      room = Room[params[:id]]
      halt 404, erb(:error, locals: { message: "Ruang tidak ditemukan." }) unless room

      if room.destroy
        redirect '/rooms'
      else
        halt 500, erb(:error, locals: { message: "Gagal menghapus ruang." })
      end
    end

    # ========== TIMESLOT ROUTES ==========
    
    # Tampilkan semua waktu
    get '/timeslots' do
      format = request.accept.first.to_sym
      @timeslots = Timeslot.all

      if format == :json
        respond_with(@timeslots, format: :json)
      else
        erb :timeslots
      end
    end

    # Form tambah waktu
    get '/timeslots/new' do
      erb :new_timeslot
    end

    # Tambah waktu
    post '/timeslots' do
      timeslot = Timeslot.new(start_time: params[:start_time], end_time: params[:end_time]) 
      if timeslot.save
        redirect '/timeslots'
      else
        halt 400, erb(:error, locals: { message: "Gagal menambahkan waktu: #{timeslot.errors.full_messages.join(', ')}" })
      end
    end

    # Form edit waktu
    get '/timeslots/:id/edit' do
      @timeslot = Timeslot[params[:id]]
      halt 404, erb(:error, locals: { message: "Waktu tidak ditemukan." }) unless @timeslot

      erb :edit_timeslot
    end

    # Edit waktu
    put '/timeslots/:id' do
      timeslot = Timeslot[params[:id]]
      halt 404, erb(:error, locals: { message: "Waktu tidak ditemukan." }) unless timeslot

      if timeslot.update(
        start_time: params[:start_time],
        end_time: params[:end_time]
      )
        redirect '/timeslots'
      else
        halt 400, erb(:error, locals: { message: "Gagal mengupdate waktu: #{timeslot.errors.full_messages.join(', ')}" })
      end
    end

    # Hapus waktu
    delete '/timeslots/:id' do
      timeslot = Timeslot[params[:id]]
      halt 404, erb(:error, locals: { message: "Waktu tidak ditemukan." }) unless timeslot

      if timeslot.destroy
        redirect '/timeslots'
      else
        halt 500, erb(:error, locals: { message: "Gagal menghapus waktu." })
      end
    end

    # ========== SCHEDULE ROUTES ==========

    # Tampilkan jadwal
    get '/schedules' do
      format = request.accept.first.to_sym
      @schedules = Schedule.all
      @doctors = Doctor.all
      @rooms = Room.all
      @timeslots = Timeslot.all

      if format == :json
        respond_with(@schedules, format: :json)
      else
        erb :schedules
      end
    end

    # Form tambah jadwal
    get '/schedules/new' do
      erb :new_schedule
    end

    # Tambah jadwal
    post '/schedules' do
      schedule = Schedule.new(
        doctor_id: params[:doctor_id],
        room_id: params[:room_id],
        timeslot_id: params[:timeslot_id],
        date: params[:date],
        max_patients: params[:max_patients]
      )
      if schedule.save
        redirect '/schedules'
      else
        halt 400, erb(:error, locals: { message: "Gagal menambahkan jadwal: #{schedule.errors.full_messages.join(', ')}" })
      end
    end

    # Form edit jadwal
    get '/schedules/:id/edit' do
      @schedule = Schedule[params[:id]]
      halt 404, erb(:error, locals: { message: "Jadwal tidak ditemukan." }) unless @schedule

      @doctors = Doctor.all
      @rooms = Room.all
      @timeslots = Timeslot.all
      erb :edit_schedule
    end

    # Edit jadwal
    put '/schedules/:id' do
      schedule = Schedule[params[:id]]
      halt 404, erb(:error, locals: { message: "Jadwal tidak ditemukan." }) unless schedule

      if schedule.update(
        doctor_id: params[:doctor_id],
        room_id: params[:room_id],
        timeslot_id: params[:timeslot_id],
        date: params[:date],
        max_patients: params[:max_patients]
      )
        redirect '/schedules'
      else
        halt 400, erb(:error, locals: { message: "Gagal mengupdate jadwal: #{schedule.errors.full_messages.join(', ')}" })
      end
    end

    # Hapus jadwal
    delete '/schedules/:id' do
      schedule = Schedule[params[:id]]
      halt 404, erb(:error, locals: { message: "Jadwal tidak ditemukan." }) unless schedule

      if schedule.destroy
        redirect '/schedules'
      else
        halt 500, erb(:error, locals: { message: "Gagal menghapus jadwal." })
      end
    end

    # Error Handling
    error do
      erb :error, locals: { message: env['sinatra.error'].message }
    end
  end
end
