Sequel.migration do
  change do
    create_table :appointments do
      primary_key :id
      Integer :patient_id, null: false
      Integer :doctor_id, null: false
      DateTime :date, null: false
      String :notes
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      foreign_key [:patient_id], :patients, key: :id, on_delete: :cascade
      foreign_key [:doctor_id], :doctors, key: :id, on_delete: :cascade
    end
  end
end
