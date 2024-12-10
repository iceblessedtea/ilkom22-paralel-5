require 'sequel'
require 'securerandom'
require_relative 'db_config'

class Schedule < Sequel::Model(:schedules)
  many_to_one :doctor
  many_to_one :room
  many_to_one :timeslot

  # Hook untuk memastikan ID adalah UUID
  def before_create
    self.id ||= SecureRandom.uuid
    super
  end

  def validate
    super
    validates_presence [:doctor_id, :room_id, :timeslot_id, :date, :max_patients]
  end
  
end
