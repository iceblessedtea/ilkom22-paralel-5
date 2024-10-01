require 'sinatra'
require 'sinatra/activerecord'
require 'json'

puts "API.rb is running"

set :database_file, 'config/database.yml'

# Definisikan model Administrator
class Administrator < ActiveRecord::Base
end

module HealthService
  class App < Sinatra::Base
    # Render halaman welcome
    get '/' do
      erb :index  # Menampilkan view index.erb
    end

    # Menampilkan list administrator dari database dalam format HTML
    get '/adm' do
      @adms = Administrator.all
      erb :admin  # Menampilkan view admin.erb
    end

    # Menampilkan data administrator berdasarkan id
    get '/adm/:id' do
      @adm = Administrator.find_by(id: params[:id])
      
      if @adm
        erb :admin_detail  # Tambahkan view admin_detail.erb untuk detail admin
      else
        "Administrator tidak ditemukan"
      end
    end

    # Route untuk memanggil service patient
    get '/patients' do
      content_type :json
      begin
        # Ganti URL di bawah dengan URL service "Patient" 
        response = RestClient.get 'http://localhost:9293/patients'
        response.body
      rescue RestClient::ExceptionWithResponse => e
        status 500
        {error: "Gagal mengambil data pasien", message: e.message}.to_json
      end
    end
  end
end
