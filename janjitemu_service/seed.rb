require 'sequel'

DB = Sequel.sqlite('janji_temu.db')

# Menambah data pasien
#DB[:patients].insert(name: "John Doe", age: 30, disease: "Demam", admitted_on: "2024-09-25")
#DB[:patients].insert(name: "Jane Smith", age: 45, disease: "Hipertensi", admitted_on: "2024-09-26")

DB[:doctors].where(name: "Dr. John Smith").update(
  specialization: "Kardiologi",
  years_of_experience: 10,
  working_since: "2014-01-01"  # Sesuaikan tanggal bulan/hari jika diperlukan
)

# Update data Dr. Emily Johnson
DB[:doctors].where(name: "Dr. Emily Johnson").update(
  specialization: "Pediatri",
  years_of_experience: 15,
  working_since: "2009-01-01"  # Sesuaikan tanggal bulan/hari jika diperlukan
)

 #Menambah data dokter
#DB[:doctors].insert(name: "Dr. John Smith", specialization: "Kardiologi", years_of_experience: 10, working_since: "2014")
#DB[:doctors].insert(name: "Dr. Emily Johnson", specialization: "Pediatri", years_of_experience: 15, working_since: "2009")
#DB[:doctors].insert(name: "Dr. Dimsss", specialization: "Jantung", years_of_experience: 20, working_since: "2004-04-09")
#DB[:doctors].insert(name: "Dr. Eko", specialization: "Saraf", years_of_experience: 15, working_since: "2009-09-04")

# Menambah data janji temu
#DB[:appointments].insert(patient_id: 1, doctor_id: 2, date: "2024-10-05", time: "10:00 AM", description: "Konsultasi anak demam")
#DB[:appointments].insert(patient_id: 2, doctor_id: 1, date: "2024-10-06", time: "02:00 PM", description: "Kontrol tekanan darah")
