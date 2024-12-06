require 'sinatra'
require 'sinatra/activerecord'
require_relative './config/database'
require_relative './app/models/dokter'

# Rute untuk menampilkan daftar dokter
get '/dokters' do
  @dokters = Dokter.all
  erb :'dokter/index_dokter'
end

# Rute untuk menampilkan form penambahan dokter
get '/dokters/new' do
  erb :'dokter/new_dokter'
end

# Rute untuk menambahkan dokter baru
post '/dokters' do
  dokter = Dokter.new(params)
  if dokter.save
    redirect '/dokters'
  else
    @errors = dokter.errors.full_messages
    erb :'dokter/new_dokter'
  end
end
