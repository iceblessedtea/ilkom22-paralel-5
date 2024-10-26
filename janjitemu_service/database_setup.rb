require 'sequel'

# Koneksi ke database SQLite
DB = Sequel.sqlite('janji_temu.db')

# Membuat tabel 'patients' untuk menyimpan data pasien
DB.create_table? :patients do
  primary_key :id
  String :name
  Integer :age
  String :disease
  Date :admitted_on
end

# Membuat tabel 'doctors' untuk menyimpan data dokter
DB.create_table? :doctors do
  primary_key :id
  String :name
  String :specialization
  Integer :years_of_experience
  Date :working_since
end

# Membuat tabel 'appointments' untuk menyimpan data janji temu
DB.create_table? :appointments do
  primary_key :id
  foreign_key :patient_id, :patients
  foreign_key :doctor_id, :doctors
  Date :date
  String :time
  String :description
end

puts "Database dan tabel berhasil dibuat!"
