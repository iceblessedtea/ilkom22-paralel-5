Sequel.migration do
  change do
    create_table :doctors do
      String :id, primary_key: true 
      String :name, null: false
      String :specialization, null: false
      String :phone, null: false
      Integer :work_since, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
