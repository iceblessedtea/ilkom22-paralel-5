ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = ENV.fetch("TEST_DATABASE_URL", "postgres://healthcare:healthcare@localhost:5432/doctor_service_test")
ENV["APPOINTMENT_URL"] = "http://localhost:7862"

require "rack/test"
require "sequel"
require "sequel/extensions/migration"

require_relative "../app/api"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    db = DoctorService::API::DB
    Sequel::Migrator.run(db, File.expand_path("../db/migrations", __dir__))
  end

  config.before do
    DoctorService::API::DB[:schedules].delete
    DoctorService::API::DB[:timeslots].delete
    DoctorService::API::DB[:rooms].delete
    DoctorService::API::DB[:doctors].delete
  end
end
