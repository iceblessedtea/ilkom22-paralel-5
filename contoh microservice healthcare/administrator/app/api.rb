require 'Sinatra'
require 'json'

module HealthService
  class Administrator < Sinatra::Base
    get '/' do
      content_type :json
      {message: "Selamat Datang :)"}.to_json
    end

    get '/adm' do
      adms = [
        {"id" => 1, "name" => "Irham Hasbi"},
        {"id" => 2, "name" => "Dhany Ramadhan"},
        {"id" => 3, "name" => "Muhammad Dimas"}
      ]
      content_type :json
      {'succes' => true, 'data' => adms}.to_json
    end

    # Menampilkan data administrator berdasarkan id
    get '/adm/:id' do
      content_type :json
      adm = adms.find {|adm| pt[:id] == params[:id].to_i}
      if adm
        adm.to_json
      else
        {mesaage: "administator tidak ditemukan"}.to_json
      end
    end
    
    #CRUD ADMINISTRATOR
    get '/adm' do
      p arr_adms
    end

    post '/adm' do
      adms.save
    end

    #CRUD QUEUE
    get '/queue' do
      p arr_queue
    end

    post '/queue' do
      queue.save(req.body)
    end

  end
end
  
