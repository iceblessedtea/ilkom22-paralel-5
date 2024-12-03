require 'sinatra'
require 'sinatra/json'
require './config/database'
require './app/routes/dokter_routes'

# Main entry point
class DokterService < Sinatra::Base
  register Sinatra::Namespace

  # Include Dokter Routes
  use DokterRoutes

  # Default route
  get '/' do
    json message: 'Welcome to Dokter Service API'
  end
end

run DokterService.run!
