Sequel.migration do
  change do
    create_table :schedules do
      primary_key :id
      foreign_key :room_id, :rooms, null: false, on_delete: :cascade
      foreign_key :timeslot_id, :timeslots, null: false, on_delete: :cascade
      foreign_key :doctor_id, :doctors, null: false, on_delete: :cascade
      Date :date, null: false
      DateTime :created_at, null: false
      DateTime :updated_at, null: false
    end
  end
end
