require 'sinatra'
require 'sinatra/json'
require 'erb'
require_relative './app/routes/pasien_routes'
require_relative './config/database'

class API < Sinatra::Base
  configure do
    set :bind, '0.0.0.0'
    set :port, 4567
    enable :logging
    set :views, 'views'
    set :public_folder, 'public'
  end

  # Halaman login
  get '/' do
    erb :login
  end

  # Proses login
  post '/login' do
    username = params[:username]
    password = params[:password]
    role = params[:role]

    # Autentikasi berdasarkan role
    if role == 'user'
      pasien = PasienController.login(username, password)
      if pasien
        @user = { nama: pasien.nama, username: pasien.username }
        @role = 'User (Pasien)'
        erb :dashboard
      else
        status 401
        return "Invalid username or password for User."
      end
    elsif role == 'admin'
      # Admin login logic (Dokter service)
      # Contoh: Fetch dari API Dokter Service di sini
      status 401
      return "Login for Admin not implemented yet."
    else
      status 400
      return "Invalid role selected."
    end
  end

  # Rute Pasien
  use PasienRoutes
end
