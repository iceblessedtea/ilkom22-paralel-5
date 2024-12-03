require 'bcrypt'

class Dokter < Sequel::Model
  plugin :validation_helpers
  plugin :secure_password, include_validations: true

  def validate
    super
    validates_presence [:name, :email, :specialization]
    validates_unique :email
  end
end
