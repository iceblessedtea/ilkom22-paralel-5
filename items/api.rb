# app.rb
require 'sinatra'
require 'json'

module ItemService
  class API < Sinatra::Base 
      # Simulasi database
      datamahasiswa = [
        { id: 1, name: "Ilham Arief", nim: "F1G122025" },
        { id: 2, name: "Muh. Faizal", nim: "F1G122024" },
        { id: 3, name: "Bintang", nim: "F1G122026" },
      ]


      get '/' do
        content_type:json
      'halo semuanya ini sudah berhasil yey'.to_json
      end

      get '/posts' do
        content_type :json
        datamahasiswa.to_json
      end

      get '/posts/:id' do
        content_type :json
        {'id'=> '1000'}.to_json
      end
  end
end
