# frozen_string_literal: true

require "sequel"
require "sequel/extensions/migration"

database_url = ENV.fetch("DATABASE_URL", "sqlite://db/patients.db")
database = Sequel.connect(database_url)
migrations_path = File.expand_path("migrations", __dir__)

Sequel::Migrator.run(database, migrations_path)
puts "Patient database migrations are up to date."
