require 'sinatra'
require 'json'
module HealthService
    class PASIEN < Sinatra::Base

      pasien = [
        {"ID" => "Z001","name" => 'Ruto' },
        {"ID" => "Z002","name" => 'Uwo' },
        {"ID" => "Z003","name" => 'Yujin' },
        {"ID" => "Z004","name" => 'Hiyyih' },
    ]
        get '/' do
            content_type :json
            {'message' => 'Health service is UP!'}.to_json
        end
        
        get '/pasien' do
            content_type :json
            {'success' => true, 'data' => pasien}.to_json
        end

        get '/pasien/:id' do
          pasien_found = pasien.find{ |d| d["ID"] == params['id']}
          if pasien_found
            content_type :json
            {'success' => true, 'data' => pasien_found}.to_json
          else
            halt 404, {'success' => false, 'message' => 'Pasien tidak ditemukan'}.to_json
          end
        end

        # CRUD PASIEN
        get '/pasien' do
            p arr_pasien
        end

        post '/pasien' do
            pasien.save
        end

        # CRUD PERWATAN
        get '/perawatan' do
            p arr_perawatan
        end

        post '/perawatan' do
            perawatan.save(req.body)
        end
    end
end