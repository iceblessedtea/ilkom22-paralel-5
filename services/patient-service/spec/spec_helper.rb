ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = ENV.fetch("TEST_DATABASE_URL", "postgres://healthcare:healthcare@localhost:5432/patient_service_test")
ENV["MEDICAL_RECORD_URL"] = "http://localhost:7863"
ENV["DOCTOR_URL"] = "http://localhost:7861"

require "rack/test"
require "sequel"
require "sequel/extensions/migration"

require_relative "../app/api"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    db = PatientService::API::DB
    Sequel::Migrator.run(db, File.expand_path("../db/migrations", __dir__))
  end

  config.before do
    PatientService::API::DB[:patients].delete
  end
end
