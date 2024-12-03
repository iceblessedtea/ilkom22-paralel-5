require 'sinatra'
require 'sinatra/json'
require_relative './app/routes/pasien_routes'
require_relative './config/database'

class API < Sinatra::Base
  configure do
    set :bind, '0.0.0.0'
    set :port, 4567
    enable :logging
  end

  before do
    content_type 'application/json'
  end

  # Load routes
  use PasienRoutes

  # Health check
  get '/' do
    json message: 'Pasien Service is running'
  end
end
