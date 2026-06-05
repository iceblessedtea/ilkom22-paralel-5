ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://#{File.expand_path("tmp/test-appointments.db", __dir__)}"
ENV["PATIENT_URL"] = "http://localhost:7860"
ENV["DOCTOR_URL"] = "http://localhost:7861"

require "fileutils"
require "rack/test"
require "sequel"
require "sequel/extensions/migration"

FileUtils.mkdir_p(File.expand_path("tmp", __dir__))
FileUtils.rm_f(File.expand_path("tmp/test-appointments.db", __dir__))
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
