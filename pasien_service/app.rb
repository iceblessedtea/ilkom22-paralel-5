require 'sinatra'
require 'sinatra/activerecord'

set :bind, '0.0.0.0' # Mengizinkan akses dari semua interface
set :database_file, 'config/database.yml'

class Patient < ActiveRecord::Base
end

class PatientService < Sinatra::Base  # Pastikan aplikasi Sinatra ada dalam class PatientService
  # Mendefinisikan route untuk aplikasi
  get '/' do
    erb :'patients/home'
  end

  get '/patients' do
    @patients = Patient.all
    erb :'patients/index'
  end

  get '/patients/new' do
    erb :'patients/new'
  end

  post '/patients' do
    patient = Patient.new(params[:patient])
    if patient.save
      redirect '/patients'
    else
      erb :'patients/new'
    end
  end

  get '/patients/:id' do
    @patient = Patient.find(params[:id])
    erb :'patients/show'
  end

  get '/patients/:id/edit' do
    @patient = Patient.find(params[:id])
    erb :'patients/edit'
  end

  put '/patients/:id' do
    @patient = Patient.find(params[:id])
    if @patient.update(params[:patient])
      redirect '/patients'
    else
      erb :'patients/edit'
    end
  end

  delete '/patients/:id' do
    @patient = Patient.find(params[:id])
    @patient.destroy
    redirect '/patients'
  end
end
