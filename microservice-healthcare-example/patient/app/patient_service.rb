require 'sinatra'
require 'json'

set :bind, '0.0.0.0'
set :port, 4568

module HealthService
  class Patient < Sinatra::Base
    get '/patients' do
      content_type :json
      patients = [
        {"id" => 1, "name" => "John Doe", "age" => 35},
        {"id" => 2, "name" => "Jane Doe", "age" => 30}
      ]
      {'success' => true, 'data' => patients}.to_json

      get '/' do
        "Hello World"
      end

    end
  end
end
