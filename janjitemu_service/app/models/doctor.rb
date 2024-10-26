require 'sequel'

DB = Sequel.sqlite('janji_temu.db')

class Doctor < Sequel::Model(:doctors)
end
