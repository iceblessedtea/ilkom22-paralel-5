Sequel.migration do
  change do
    create_table(:dokters) do
      primary_key :id
      String :nama, null: false
      String :spesialisasi
      String :nomor_telepon
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
