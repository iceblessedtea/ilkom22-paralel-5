require 'sinatra'
require 'json'

puts "API.rb is running"

module HealthService
  class Administrator < Sinatra::Base
    # Render halaman welcome
    get '/' do
      erb :index  # Menampilkan view index.erb
    end

    # Menampilkan list administrator dalam format HTML
    get '/adm' do
      @adms = [
        {"id" => 1, "name" => "Irham Hasbi"},
        {"id" => 2, "name" => "Dhany Ramadhan"},
        {"id" => 3, "name" => "Muhammad Dimas"}
      ]
      erb :admin  # Menampilkan view admin.erb
    end

    # Menampilkan data administrator berdasarkan id
    get '/adm/:id' do
      adms = [
        {"id" => 1, "name" => "Irham Hasbi"},
        {"id" => 2, "name" => "Dhany Ramadhan"},
        {"id" => 3, "name" => "Muhammad Dimas"}
      ]
      @adm = adms.find { |adm| adm["id"] == params[:id].to_i }
      
      if @adm
        erb :admin_detail  # Tambahkan view admin_detail.erb untuk detail admin
      else
        "Administrator tidak ditemukan"

        # Route untuk memanggil service patient
        get '/patients' do
          content_type :json
          begin
            # Ganti URL di bawah dengan URL service "Patient" Anda
            response = RestClient.get 'http://localhost:9293/patients'
            response.body
          rescue RestClient::ExceptionWithResponse => e
            status 500
            {error: "Gagal mengambil data pasien", message: e.message}.to_json
          end
        end
      end
    end
  end
end
