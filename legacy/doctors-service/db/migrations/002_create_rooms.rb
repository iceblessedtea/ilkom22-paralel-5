Sequel.migration do
  change do
    create_table :rooms do
      String :id, primary_key: true
      String :name, null: false, unique: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
