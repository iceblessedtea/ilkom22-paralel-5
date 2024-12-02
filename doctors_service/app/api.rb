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
      enable :method_override
      set :allow_methods, [:get, :post, :put, :delete, :options]
      set :public_folder, File.dirname(__FILE__) + '/public'
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

    # Route untuk halaman utama
    get '/' do
      erb :welcome
    end

    # Route untuk menampilkan data dokter
    get '/doctors' do
      @doctors = doctors.all 
      p @doctors
      erb :doctors
    end

    # Route untuk form tambah dokter
    get '/doctors/new' do
      erb :new_doctor
    end

    # Route untuk menambah dokter
    post '/doctors' do
      if params[:name].strip.empty? || params[:specialization].strip.empty? || params[:phone].strip.empty? || params[:work_since].strip.empty?
        halt 400, erb(:error, locals: { message: "Semua bidang harus diisi!" })
      end
    
      doctor_param = {
        name: params[:name],
        specialization: params[:specialization],
        phone: params[:phone],
        work_since: params[:work_since].to_i,  
        created_at: Time.now,
        updated_at: Time.now
      }

      max_id = doctors.max(:id) || 0
      doctor_param[:id] = max_id + 1

      res = doctors.insert(doctor_param)

      if res
        redirect to('/doctors')
      else
        halt 500, erb(:error, locals: { message: "Gagal menambahkan dokter." })
      end
    end

    # Route untuk form edit dokter
    get '/doctors/:id/edit' do
      @doctor = doctors.where(id: params[:id]).first
      halt 404, erb(:error, locals: { message: "Dokter tidak ditemukan." }) unless @doctor

      erb :edit_doctor
    end

    # Route untuk mengedit dokter
    put '/doctors/:id' do
      doctor_param = {
        name: params[:name],
        specialization: params[:specialization],
        phone: params[:phone],
        work_since: params[:work_since].to_i,
        updated_at: Time.now
      }

      res = doctors.where(id: params[:id]).update(doctor_param)

      if res > 0
        redirect to('/doctors')
      else
        halt 500, erb(:error, locals: { message: "Gagal mengupdate data dokter." })
      end
    end

    # Route untuk menghapus dokter
    delete '/doctors/:id' do
      res = doctors.where(id: params[:id]).delete

      if res > 0
        redirect to('/doctors')
      else
        halt 500, erb(:error, locals: { message: "Gagal menghapus data dokter." })
      end
    end

    # Error Handling
    error do
      erb :error, locals: { message: "Terjadi kesalahan pada server." }
    end
  end
end
