require 'sinatra'
require_relative './api'

set :port, 4567

get '/' do
  redirect '/dokters'
end

run Sinatra::Application.run!
