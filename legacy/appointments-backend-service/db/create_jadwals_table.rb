require 'sqlite3'

DB = SQLite3::Database.new('development.sqlite3')

# Membuat tabel jadwals
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS jadwals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    dokter_id INTEGER,
    tanggal DATE,
    waktu TIME,
    pasien_nama STRING,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dokter_id) REFERENCES dokters(id)
  );
SQL

puts "Tabel jadwals telah dibuat atau sudah ada."

