require 'sequel'

DB = Sequel.sqlite('janji_temu.db')

class Appointment < Sequel::Model(:appointments)
  plugin :validation_helpers  # Tambahkan plugin validation_helpers
  
  many_to_one :patient
  many_to_one :doctor
  
  def before_create
    # Get all existing IDs and sort them
    existing_ids = Appointment.select(:id).map(&:id).sort
    
    # Find the smallest available ID (gap)
    next_id = 1
    existing_ids.each do |id|
      break if id != next_id
      next_id += 1
    end
    
    # Set new ID to smallest gap found
    self.id = next_id
    super
  end

  def validate
    super
    validates_presence [:patient_id, :doctor_id, :date, :time, :description], message: 'tidak boleh kosong'
  end
end