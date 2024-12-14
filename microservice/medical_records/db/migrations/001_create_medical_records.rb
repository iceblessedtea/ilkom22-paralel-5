Sequel.migration do
  change do
    create_table :medical_records do
      primary_key :id
      foreign_key :patient_id, :patients, null: false, on_delete: :cascade
      String :diagnosis, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
