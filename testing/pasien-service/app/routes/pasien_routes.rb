require 'sinatra/base'
require_relative '../controllers/pasien_controller'

class PasienRoutes < Sinatra::Base
  get '/pasiens' do
    json PasienController.index.map { |p| { id: p.id, nama: p.nama, umur: p.umur, username: p.username } }
  end

  post '/pasiens' do
    data = JSON.parse(request.body.read)
    PasienController.create(data)
    status 201
  end

  post '/login' do
    data = JSON.parse(request.body.read)
    pasien = PasienController.login(data['username'], data['password'])
    if pasien
      json id: pasien.id, nama: pasien.nama, username: pasien.username
    else
      status 401
      json message: 'Invalid credentials'
    end
  end
end
