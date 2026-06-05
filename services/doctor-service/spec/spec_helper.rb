ENV["RACK_ENV"] = "test"
ENV["DATABASE_URL"] = "sqlite://#{File.expand_path("tmp/test-doctors.db", __dir__)}"
ENV["APPOINTMENT_URL"] = "http://localhost:7862"

require "fileutils"
require "rack/test"

FileUtils.mkdir_p(File.expand_path("tmp", __dir__))
require_relative "../app/api"

RSpec.configure do |config|
  config.include Rack::Test::Methods

  config.before(:suite) do
    db = DoctorService::API::DB
    db.drop_table?(:doctors)
    db.create_table :doctors do
      primary_key :id
      String :name
      String :specialization
      Time :created_at
      Time :updated_at
    end
  end

  config.before do
    DoctorService::API::DB[:doctors].delete
  end
end
