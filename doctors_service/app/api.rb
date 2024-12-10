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
    def respond_with(data)
      content_type :json
      data.to_json
    end

    # Route untuk halaman utama
    get '/' do
      respond_with({ message: 'Welcome to the Doctor Service API' })
    end

    # ========== DOCTOR ROUTES ==========

    # Tampilkan semua dokter
    get '/doctors' do
      @doctors = Doctor.all
      respond_with(@doctors)
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
        respond_with({ message: 'Dokter berhasil ditambahkan', doctor: doctor })
      else
        halt 400, respond_with({ message: "Gagal menambahkan dokter: #{doctor.errors.full_messages.join(', ')}" })
      end
    end

    # Edit dokter
    put '/doctors/:id' do
      doctor = Doctor[params[:id]]
      halt 404, respond_with({ message: "Dokter tidak ditemukan." }) unless doctor

      if doctor.update(
        name: params[:name],
        specialization: params[:specialization],
        phone: params[:phone],
        work_since: params[:work_since]
      )
        respond_with({ message: 'Dokter berhasil diperbarui', doctor: doctor })
      else
        halt 400, respond_with({ message: "Gagal mengupdate dokter: #{doctor.errors.full_messages.join(', ')}" })
      end
    end

    # Hapus dokter
    delete '/doctors/:id' do
      doctor = Doctor[params[:id]]
      halt 404, respond_with({ message: "Dokter tidak ditemukan." }) unless doctor

      if doctor.destroy
        respond_with({ message: 'Dokter berhasil dihapus' })
      else
        halt 500, respond_with({ message: "Gagal menghapus dokter." })
      end
    end

    # ========== ROOM ROUTES ==========

    # Tampilkan semua ruang
    get '/rooms' do
      @rooms = Room.all
      respond_with(@rooms)
    end

    # Tambah ruang
    post '/rooms' do
      room = Room.new(name: params[:name])
      if room.save
        respond_with({ message: 'Ruang berhasil ditambahkan', room: room })
      else
        halt 400, respond_with({ message: "Gagal menambahkan ruang: #{room.errors.full_messages.join(', ')}" })
      end
    end

    # Edit ruang
    put '/rooms/:id' do
      room = Room[params[:id]]
      halt 404, respond_with({ message: "Ruang tidak ditemukan." }) unless room

      if room.update(name: params[:name])
        respond_with({ message: 'Ruang berhasil diperbarui', room: room })
      else
        halt 400, respond_with({ message: "Gagal mengupdate ruang: #{room.errors.full_messages.join(', ')}" })
      end
    end

    # Hapus ruang
    delete '/rooms/:id' do
      room = Room[params[:id]]
      halt 404, respond_with({ message: "Ruang tidak ditemukan." }) unless room

      if room.destroy
        respond_with({ message: 'Ruang berhasil dihapus' })
      else
        halt 500, respond_with({ message: "Gagal menghapus ruang." })
      end
    end

    # ========== TIMESLOT ROUTES ==========
    
    # Tampilkan semua waktu
    get '/timeslots' do
      @timeslots = Timeslot.all
      respond_with(@timeslots)
    end

    # Tambah waktu
    post '/timeslots' do
      timeslot = Timeslot.new(start_time: params[:start_time], end_time: params[:end_time]) 
      if timeslot.save
        respond_with({ message: 'Waktu berhasil ditambahkan', timeslot: timeslot })
      else
        halt 400, respond_with({ message: "Gagal menambahkan waktu: #{timeslot.errors.full_messages.join(', ')}" })
      end
    end

    # Edit waktu
    put '/timeslots/:id' do
      timeslot = Timeslot[params[:id]]
      halt 404, respond_with({ message: "Waktu tidak ditemukan." }) unless timeslot

      if timeslot.update(
        start_time: params[:start_time],
        end_time: params[:end_time]
      )
        respond_with({ message: 'Waktu berhasil diperbarui', timeslot: timeslot })
      else
        halt 400, respond_with({ message: "Gagal mengupdate waktu: #{timeslot.errors.full_messages.join(', ')}" })
      end
    end

    # Hapus waktu
    delete '/timeslots/:id' do
      timeslot = Timeslot[params[:id]]
      halt 404, respond_with({ message: "Waktu tidak ditemukan." }) unless timeslot

      if timeslot.destroy
        respond_with({ message: 'Waktu berhasil dihapus' })
      else
        halt 500, respond_with({ message: "Gagal menghapus waktu." })
      end
    end

    # ========== SCHEDULE ROUTES ==========

    # Tampilkan jadwal
    get '/schedules' do
      @schedules = Schedule.all
      @doctors = Doctor.all
      @rooms = Room.all
      @timeslots = Timeslot.all
      respond_with(@schedules)
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
        respond_with({ message: 'Jadwal berhasil ditambahkan', schedule: schedule })
      else
        halt 400, respond_with({ message: "Gagal menambahkan jadwal: #{schedule.errors.full_messages.join(', ')}" })
      end
    end

    # Edit jadwal
    put '/schedules/:id' do
      schedule = Schedule[params[:id]]
      halt 404, respond_with({ message: "Jadwal tidak ditemukan." }) unless schedule

      if schedule.update(
        doctor_id: params[:doctor_id],
        room_id: params[:room_id],
        timeslot_id: params[:timeslot_id],
        date: params[:date],
        max_patients: params[:max_patients]
      )
        respond_with({ message: 'Jadwal berhasil diperbarui', schedule: schedule })
      else
        halt 400, respond_with({ message: "Gagal mengupdate jadwal: #{schedule.errors.full_messages.join(', ')}" })
      end
    end

    # Hapus jadwal
    delete '/schedules/:id' do
      schedule = Schedule[params[:id]]
      halt 404, respond_with({ message: "Jadwal tidak ditemukan." }) unless schedule

      if schedule.destroy
        respond_with({ message: 'Jadwal berhasil dihapus' })
      else
        halt 500, respond_with({ message: "Gagal menghapus jadwal." })
      end
    end

    # Error Handling
    error do
      respond_with({ message: env['sinatra.error'].message })
    end
  end
end
