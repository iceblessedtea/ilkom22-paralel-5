require 'sinatra'
require 'json'
module StudentService
    class API < Sinatra::Base
        get '/' do
            content_type :json
            {'message' => 'Student service is UP!'}.to_json
        end
        
        get '/students' do
            students = [
                {"ID" => "F1G122033","name" => 'Vina' },
                {"ID" => "F1G122031","name" => 'Sitti Nur Aisya' },
                {"ID" => "F1G122049","name" => 'Fitrah Rahmawati' },
            ]
            content_type :json
            {'success' => true, 'data' => students}.to_json
        end

        # CRUD CUSTOMER
        get '/customers' do
            p arr_customers
        end

        post '/customers' do
            customers.save
        end

        # CRUD ORDER
        get '/orders' do
            p arr_orders
        end

        post '/orders' do
            order.save(req.body)
        end

    end
end