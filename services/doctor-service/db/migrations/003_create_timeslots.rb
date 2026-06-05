Sequel.migration do
  change do
    create_table :timeslots do
      primary_key :id
      String :day, null: false
      String :start_time, null: false
      String :end_time, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
