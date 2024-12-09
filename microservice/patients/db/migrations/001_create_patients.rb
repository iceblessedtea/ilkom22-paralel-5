Sequel.migration do
  change do
    create_table :patients do
      primary_key :id
      String :name, null: false
      Integer :age, null: false
      String :gender, null: false
      String :address
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
