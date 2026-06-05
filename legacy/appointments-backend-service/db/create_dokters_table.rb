# create_tables.rb
require 'sqlite3'

DB = SQLite3::Database.new('development.sqlite3')

# Membuat tabel jika belum ada
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS dokters (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nama STRING,
    spesialis STRING,
    usia INTEGER,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
SQL
