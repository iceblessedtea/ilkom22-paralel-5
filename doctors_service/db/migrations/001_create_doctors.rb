Sequel.migration do
  change do
    create_table :doctors do
      primary_key :id
      String :name
      String :specialization
      String :phone
      Integer :work_since
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
