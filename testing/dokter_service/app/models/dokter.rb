require 'sequel'
DB = Sequel.connect('sqlite://db/development.sqlite3')

class Dokter < Sequel::Model
end
