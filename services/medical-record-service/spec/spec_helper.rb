ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = ENV.fetch("TEST_DATABASE_URL", "postgres://healthcare:healthcare@localhost:5432/medical_record_service_test")
ENV["PATIENT_URL"] = "http://localhost:7860"

require "rack/test"
require "sequel"
require "sequel/extensions/migration"

require_relative "../app/api"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    db = MedicalRecordService::API::DB
    Sequel::Migrator.run(db, File.expand_path("../db/migrations", __dir__))
  end

  config.before do
    MedicalRecordService::API::DB[:medical_records].delete
  end
end
