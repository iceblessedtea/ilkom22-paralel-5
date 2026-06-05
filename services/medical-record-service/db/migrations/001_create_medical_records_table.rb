Sequel.migration do
  change do
    create_table :medical_records do
      primary_key :id
      Integer :patient_id, null: false
      String :diagnosis, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
