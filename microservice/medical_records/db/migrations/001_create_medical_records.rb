Sequel.migration do
  change do
    create_table :medical_records do
      primary_key :id
      Integer :patient_id, null: false
      String :diagnosis, null: false
      String :treatment, null: false
      String :doctor_notes
      DateTime :created_at, null: false
      DateTime :updated_at, null: false

      foreign_key [:patient_id], :patients, key: :id, on_delete: :cascade
    end
  end
end
