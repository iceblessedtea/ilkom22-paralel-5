require 'sinatra'
require 'json'

module CustomersService
  class API < Sinatra::Base 
    def initialize
      super()
      @arr_customers = [
        { id: 1, name: "Ilham Arief", gender: "lakik" },
        { id: 2, name: "Muh. Faizal", gender: "lakik" },
        { id: 3, name: "Bintang", gender: "cewe" }
      ]
    end

    # Health check endpoint
    get '/' do
      content_type :json
      { 'message' => 'Customers service is UP!' }.to_json
    end

    # Fetch all customers
    get '/customers' do
      content_type :json
      { 'success' => true, 'data' => @arr_customers }.to_json
    end

    # Fetch customer by id
    get '/customer/:id' do
      id = params['id'].to_i
      customer = @arr_customers.find { |cust| cust[:id] == id }

      if customer
        content_type :json
        { 'success' => true, 'data' => customer }.to_json
      else
        content_type :json
        status 404
        { 'success' => false, 'message' => "Customer not found" }.to_json
      end
    end

    # Create new customer
    post '/customers' do
      content_type :json
      customer = JSON.parse(request.body.read, symbolize_names: true)

      # Tambah customer ke array
      customer[:id] = @arr_customers.last[:id] + 1
      @arr_customers << customer

      { 'success' => true, 'message' => 'Customer added successfully', 'data' => customer }.to_json
    end
  end
end
