require 'sqlite3'

DB = SQLite3::Database.new('development.sqlite3')

# Membuat tabel rekam_mediks
DB.execute <<-SQL
  CREATE TABLE IF NOT EXISTS rekam_mediks (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    pasien_nama STRING,
    dokter_id INTEGER,
    tanggal DATE,
    diagnosis STRING,
    treatment STRING,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dokter_id) REFERENCES dokters(id)
  );
SQL

puts "Tabel rekam_mediks telah dibuat atau sudah ada."

