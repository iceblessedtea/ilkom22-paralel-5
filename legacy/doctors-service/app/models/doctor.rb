require 'sequel'
require 'securerandom'
require_relative 'db_config'

class Doctor < Sequel::Model(:doctors)
  plugin :validation_helpers

  # Hook untuk memastikan ID adalah UUID
  def before_create
    self.id ||= SecureRandom.uuid
    super
  end

  def validate
    super
    validates_presence [:name, :specialization, :phone, :work_since]
    validates_format /\A\d+\z/, :phone, message: "Nomor telepon harus berupa angka."
    validates_integer :work_since, message: "Tahun mulai harus berupa angka."
    validates_unique :name, message: "Nama dokter sudah ada."
    end
end
