Sequel.migration do
  change do
    create_table :appointments do
      primary_key :id
      Integer :patient_id, null: false
      Integer :doctor_id, null: false
      DateTime :date, null: false
      String :notes
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
