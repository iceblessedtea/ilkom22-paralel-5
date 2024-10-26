require 'sqlite3'

# Ganti nama_database.db dengan nama database Anda
db = SQLite3::Database.new "janji_temu.db"

# Menampilkan daftar tabel
puts "Daftar Tabel:"
db.execute("SELECT name FROM sqlite_master WHERE type='table'") do |table|
  puts "- #{table[0]}"
end

# Fungsi untuk menampilkan struktur tabel
def show_table_schema(db, table_name)
  puts "\nStruktur Tabel '#{table_name}':"
  db.execute("PRAGMA table_info(#{table_name})") do |column|
    puts column.join(" | ")
  end
end

# Fungsi untuk menampilkan isi tabel
def show_table_data(db, table_name)
  puts "\nIsi Tabel '#{table_name}':"
  db.execute("SELECT * FROM #{table_name}") do |row|
    puts row.join(" | ")
  end
end

# Panggil fungsi sesuai kebutuhan
table_name = "doctors" 
# Ganti dengan nama tabel yang ingin dilihat

show_table_schema(db, table_name)
show_table_data(db, table_name)

puts "Connecting to database..."
