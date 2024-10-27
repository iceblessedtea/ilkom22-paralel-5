# app.rb
require 'sinatra'
require 'sinatra/activerecord'
require './models/patient'

set :database_file, 'config/database.yml'

# Tampilkan daftar pasien
get '/patients' do
  @patients = Patient.all
  erb :'patients/index'
end

# Tampilkan form untuk menambah pasien baru
get '/patients/new' do
  erb :'patients/new'
end

# Buat pasien baru
post '/patients' do
  patient = Patient.new(params)
  if patient.save
    redirect '/patients'
  else
    erb :'patients/new'
  end
end

# Tampilkan detail pasien
get '/patients/:id' do
  @patient = Patient.find(params[:id])
  erb :'patients/show'
end

# Tampilkan form untuk mengedit pasien
get '/patients/:id/edit' do
  @patient = Patient.find(params[:id])
  erb :'patients/edit'
end

# Update pasien
put '/patients/:id' do
  @patient = Patient.find(params[:id])
  if @patient.update(params)
    redirect '/patients'
  else
    erb :'patients/edit'
  end
end

# Hapus pasien
delete '/patients/:id' do
  @patient = Patient.find(params[:id])
  @patient.destroy
  redirect '/patients'
end
