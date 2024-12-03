require 'sinatra/base'
require 'sinatra/json'
require_relative '../models/dokter'

class DokterRoutes < Sinatra::Base
  get '/dokters' do
    @dokters = Dokter.all
    erb :'dokters/index'
  end

  get '/dokters/new' do
    @dokter = Dokter.new
    erb :'dokters/form'
  end

  post '/dokters' do
    Dokter.create(params.slice('nama', 'spesialisasi', 'nomor_telepon'))
    redirect '/dokters'
  end

  get '/dokters/:id/edit' do
    @dokter = Dokter[params[:id]]
    erb :'dokters/form'
  end

  put '/dokters/:id' do
    dokter = Dokter[params[:id]]
    dokter.update(params.slice('nama', 'spesialisasi', 'nomor_telepon'))
    redirect '/dokters'
  end

  delete '/dokters/:id' do
    Dokter[params[:id]].delete
    redirect '/dokters'
  end
end
