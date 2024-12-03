require 'sqlite3'
require 'sequel'

DB = Sequel.sqlite('db/development.sqlite3')

# Load models
Dir[File.join(File.dirname(__FILE__), '../app/models', '*.rb')].each { |file| require file }
