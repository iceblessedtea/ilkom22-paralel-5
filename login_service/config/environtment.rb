require 'sinatra/activerecord'
require 'sinatra'
require_relative '../models/user'

# Load database config
set :database_file, './config/database.yml'
