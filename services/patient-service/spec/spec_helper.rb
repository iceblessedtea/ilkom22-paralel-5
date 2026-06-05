ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://#{File.expand_path("tmp/test-patients.db", __dir__)}"
ENV["MEDICAL_RECORD_URL"] = "http://localhost:7863"
ENV["DOCTOR_URL"] = "http://localhost:7861"

require "fileutils"
require "rack/test"
require "sequel"
require "sequel/extensions/migration"

FileUtils.mkdir_p(File.expand_path("tmp", __dir__))
FileUtils.rm_f(File.expand_path("tmp/test-patients.db", __dir__))
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
