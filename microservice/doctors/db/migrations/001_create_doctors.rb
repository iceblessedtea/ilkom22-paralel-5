Sequel.migration do
  change do
    create_table :doctors do
      primary_key :id
      String :name, null: false
      String :specialization, null: false
      String :phone
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
