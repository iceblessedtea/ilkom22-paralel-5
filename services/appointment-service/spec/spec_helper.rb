ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://#{File.expand_path("tmp/test-appointments.db", __dir__)}"
ENV["PATIENT_URL"] = "http://localhost:7860"
ENV["DOCTOR_URL"] = "http://localhost:7861"

require "fileutils"
require "rack/test"

FileUtils.mkdir_p(File.expand_path("tmp", __dir__))
require_relative "../app/api"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    db = AppointmentService::API::DB
    db.drop_table?(:appointments)
    db.create_table :appointments do
      primary_key :id
      Integer :patient_id
      Integer :doctor_id
      String :date
      String :notes
      Time :created_at
      Time :updated_at
    end
  end

  config.before do
    AppointmentService::API::DB[:appointments].delete
  end
end
