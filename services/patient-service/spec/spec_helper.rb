ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://#{File.expand_path("tmp/test-patients.db", __dir__)}"
ENV["MEDICAL_RECORD_URL"] = "http://localhost:7863"
ENV["DOCTOR_URL"] = "http://localhost:7861"

require "fileutils"
require "rack/test"

FileUtils.mkdir_p(File.expand_path("tmp", __dir__))
require_relative "../app/api"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    db = PatientService::API::DB
    db.drop_table?(:patients)
    db.create_table :patients do
      primary_key :id
      String :name
      Integer :age
      String :gender
      String :address
      Time :created_at
      Time :updated_at
    end
  end

  config.before do
    PatientService::API::DB[:patients].delete
  end
end
