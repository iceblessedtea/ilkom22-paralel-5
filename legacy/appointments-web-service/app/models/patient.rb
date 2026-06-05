require 'sequel'

DB = Sequel.sqlite('janji_temu.db')

class Patient < Sequel::Model(:patients)
end
