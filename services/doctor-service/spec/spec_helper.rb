ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://#{File.expand_path("tmp/test-doctors.db", __dir__)}"
ENV["APPOINTMENT_URL"] = "http://localhost:7862"

require "fileutils"
require "rack/test"
require "sequel"
require "sequel/extensions/migration"

FileUtils.mkdir_p(File.expand_path("tmp", __dir__))
FileUtils.rm_f(File.expand_path("tmp/test-doctors.db", __dir__))
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
