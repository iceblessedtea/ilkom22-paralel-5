require 'sequel'
require 'securerandom'
require_relative 'db_config'

class Room < Sequel::Model(:rooms)
  plugin :validation_helpers

  # Hook untuk memastikan ID adalah UUID
  def before_create
    self.id ||= SecureRandom.uuid
    super
  end

  def validate
    super
    validates_presence [:name]
    validates_unique :name, message: "Nama ruang sudah ada."
  end
end
