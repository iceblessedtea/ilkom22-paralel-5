Sequel.migration do
  change do
    create_table :timeslots do
      String :id, primary_key: true
      String :day, null: false
      String :start_time, null: false
      String :end_time, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end
