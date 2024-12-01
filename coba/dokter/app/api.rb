require 'sinatra'
require 'json'
module HealthService
    class DOKTER < Sinatra::Base

      dokter = [
        {"ID" => "B001","name" => 'Nazwah Thalbiatul Ilmi' },
        {"ID" => "B002","name" => 'Putri Eka Wulandari' },
        {"ID" => "B003","name" => 'Deswita Maharani' },
        {"ID" => "B004","name" => 'Khusnul Qhatimah Khamaisyah' },
    ]
        get '/' do
            content_type :json
            {'message' => 'Health service is UP!'}.to_json
        end
        
        get '/dokter' do
            content_type :json
            {'success' => true, 'data' => dokter}.to_json
        end

        get '/dokter/:id' do
          dokter_found = dokter.find{ |d| d["ID"] == params['id']}
          if dokter_found
            content_type :json
            {'success' => true, 'data' => dokter_found}.to_json
          else
            halt 404, {'success' => false, 'message' => 'Dokter tidak ditemukan'}.to_json
          end
        end

        # CRUD DOKTER
        get '/dokter' do
            p arr_dokter
        end

        post '/dokter' do
            dokter.save
        end

        # CRUD KONSULTASI
        get '/konsultasi' do
            p arr_konsultasi
        end

        post '/konsultasi' do
            konsultasi.save(req.body)
        end
    end
end