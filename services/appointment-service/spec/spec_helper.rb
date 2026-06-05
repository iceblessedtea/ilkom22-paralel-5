ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = ENV.fetch("TEST_DATABASE_URL", "postgres://healthcare:healthcare@localhost:5432/appointment_service_test")
ENV["PATIENT_URL"] = "http://localhost:7860"
ENV["DOCTOR_URL"] = "http://localhost:7861"

require "rack/test"
require "sequel"
require "sequel/extensions/migration"

require_relative "../app/api"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    db = AppointmentService::API::DB
    Sequel::Migrator.run(db, File.expand_path("../db/migrations", __dir__))
  end

  config.before do
    AppointmentService::API::DB[:appointments].delete
  end
end
