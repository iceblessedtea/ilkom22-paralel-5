Sequel.migration do
  change do
    create_table :schedules do
      String :id, primary_key: true
      foreign_key :room_id, :rooms, null: false, on_delete: :cascade
      foreign_key :timeslot_id, :timeslots, null: false, on_delete: :cascade
      foreign_key :doctor_id, :doctors, null: false, on_delete: :cascade
      Date :date, null: false
      Integer :max_patients, null: false
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      DateTime :updated_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end