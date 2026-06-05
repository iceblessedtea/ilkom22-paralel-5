require 'sequel'
require 'securerandom'
require_relative 'db_config'

class Timeslot < Sequel::Model(:timeslots)
  plugin :validation_helpers

  # Hook untuk memastikan ID adalah UUID
  def before_create
    self.id ||= SecureRandom.uuid
    super
  end

  def validate
    super
    validates_presence [:day, :start_time, :end_time]
    validates_format /\A\d{2}:\d{2}\z/, :start_time, message: "Format waktu harus HH:MM"
    validates_format /\A\d{2}:\d{2}\z/, :end_time, message: "Format waktu harus HH:MM"
  end
end
