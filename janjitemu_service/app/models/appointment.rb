require 'sequel'

DB = Sequel.sqlite('janji_temu.db')

class Appointment < Sequel::Model(:appointments)
  many_to_one :patient
  many_to_one :doctor
end
