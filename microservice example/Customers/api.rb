require 'sinatra'
require 'json'

module CustomersService
  class API < Sinatra::Base 
    def initialize
      super()
      @arr_customers = []
      @arr_orders = []
    end

    get '/' do
      content_type :json
      { 'message' => 'Customers service is UP!' }.to_json
    end

    get '/Customers' do
      dataCustomers = [
        { id: 1, name: "Ilham Arief", gender: "lakik" },
        { id: 2, name: "Muh. Faizal", gender: "lakik" },
        { id: 3, name: "Bintang", gender: "cewe" },
      ]
      content_type :json
      { 'success' => true, 'data' => dataCustomers }.to_json
    end

    # CRUD CUSTOMER
    # get '/customers' do
    #   content_type :json
    #   { 'success' => true, 'data' => dataCustomers }.to_json
    # end

    post '/customers' do
      content_type :json
      customer = JSON.parse(request.body.read)
      dataCustomers << customer
      { 'success' => true, 'message' => 'Customer added successfully' }.to_json
    end
  end
end
