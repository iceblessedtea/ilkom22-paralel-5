require 'sinatra'
require 'json'

module OrderService
  class API < Sinatra::Base
    def initialize
      super()
      @arr_orders = []
    end

    get '/' do
      content_type :json
      {'message' => 'Order service sudah menyala '}.to_json
    end

    # CRUD ORDER
    get '/orders' do
      content_type :json
      { 'success' => true, 'data' => @arr_orders }.to_json
    end

    post '/orders' do
      content_type :json
      order = JSON.parse(request.body.read)
      @arr_orders << order
      { 'success' => true, 'message' => 'Order added successfully' }.to_json
    end

  end
end