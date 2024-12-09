require 'sinatra'
require 'json'
require 'sqlite3'
require_relative 'C:/Janji-Temu/models/dokter'
require_relative 'C:/Janji-Temu/models/jadwal'
require_relative 'C:/Janji-Temu/models/rekam_medik'

# Initialize the SQLite3 Database
DB = SQLite3::Database.new 'C:/Janji-Temu/db/development.sqlite3'
DB.results_as_hash = true

get '/' do
  'Selamat datang di API Dokter!'
end


# Route for listing all doctors
get '/doctor' do
  doctor = Dokter.all
  doctor.to_json
end

# Route for listing all general doctors
get '/doctors/umum' do
  doctors = Dokter.find_by_type('umum')
  doctors.to_json
end

# Route for listing all specialists
get '/doctors/spesialis' do
  doctors = Dokter.find_by_type('spesialis')
  doctors.to_json
end

# Route for listing doctor schedules
get '/dokter/:id/schedule' do
  dokter_id = params[:id]
  schedules = Jadwal.where(dokter_id: dokter_id)

  if schedules.empty?
    halt 404, { message: 'Schedules not found' }.to_json
  end

  schedules.to_json
end

# Route for booking an appointment (no access to medical records)
post '/appointments' do
  data = JSON.parse(request.body.read)
  # Logic for creating an appointment goes here...
  { message: 'Appointment booked' }.to_json
end

# Route for fetching a medical record
get '/rekam_medik/:id' do
  role = params[:role] || request.env['HTTP_ROLE'] # example of getting from header

  if role == 'admin'
    record = RekamMedik.find(params[:id])
    record.to_json
  else
    halt 403, { message: 'Access forbidden' }.to_json
  end
end

# Route for soft deleting a medical record
delete '/rekam_medik/:id' do
  RekamMedik.soft_delete(params[:id])
  { message: 'Medical record marked as deleted successfully' }.to_json
end
