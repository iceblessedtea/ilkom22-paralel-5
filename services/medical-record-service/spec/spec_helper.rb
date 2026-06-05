ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://#{File.expand_path("tmp/test-medical-records.db", __dir__)}"
ENV["PATIENT_URL"] = "http://localhost:7860"

require "fileutils"
require "rack/test"

FileUtils.mkdir_p(File.expand_path("tmp", __dir__))
require_relative "../app/api"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    db = MedicalRecordService::API::DB
    db.drop_table?(:medical_records)
    db.create_table :medical_records do
      primary_key :id
      Integer :patient_id
      String :diagnosis
      Time :created_at
      Time :updated_at
    end
  end

  config.before do
    MedicalRecordService::API::DB[:medical_records].delete
  end
end
