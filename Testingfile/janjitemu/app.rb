# app.rb
require 'sinatra'
require 'json'

# In-memory database untuk pasien
patients = [
  { id: 1, name: "John Doe", age: 30, disease: "Demam", admitted_on: "2024-09-25" },
  { id: 2, name: "Jane Smith", age: 45, disease: "Hipertensi", admitted_on: "2024-09-26" }
]

# In-memory database untuk dokter
doctors = [
  { id: 1, name: "Dr. John Smith", specialization: "Kardiologi", years_of_experience: 10, working_since: "2014" },
  { id: 2, name: "Dr. Emily Johnson", specialization: "Pediatri", years_of_experience: 15, working_since: "2009" }
]

# In-memory database untuk janji temu
appointments = [
  { id: 1, patient_id: 1, doctor_id: 2, date: "2024-10-05", time: "10:00 AM", description: "Konsultasi anak demam" },
  { id: 2, patient_id: 2, doctor_id: 1, date: "2024-10-06", time: "02:00 PM", description: "Kontrol tekanan darah" }
]

# Helper method untuk mencari pasien
def find_patient(patients, id)
  patients.find { |patient| patient[:id] == id }
end

# Helper method untuk mencari dokter
def find_doctor(doctors, id)
  doctors.find { |doctor| doctor[:id] == id }
end

# Helper method untuk mencari janji temu berdasarkan ID
def find_appointment(appointments, id)
  appointments.find { |appointment| appointment[:id] == id }
end

# Route untuk melihat semua janji temu (GET /appointments)
get '/appointments' do
  content_type :json
  appointments.to_json
end

# Route untuk melihat janji temu berdasarkan ID (GET /appointments/:id)
get '/appointments/:id' do
  content_type :json
  appointment = find_appointment(appointments, params['id'].to_i)

  if appointment
    appointment.to_json
  else
    halt 404, { message: 'Appointment not found' }.to_json
  end
end

# Route untuk membuat janji temu baru (POST /appointments)
post '/appointments' do
  content_type :json
  request_body = JSON.parse(request.body.read)

  # Validasi sederhana: cek apakah pasien dan dokter ada
  patient = find_patient(patients, request_body['patient_id'])
  doctor = find_doctor(doctors, request_body['doctor_id'])

  if patient && doctor && request_body['date'] && request_body['time'] && request_body['description']
    new_id = appointments.last[:id] + 1
    new_appointment = {
      id: new_id,
      patient_id: request_body['patient_id'],
      doctor_id: request_body['doctor_id'],
      date: request_body['date'],
      time: request_body['time'],
      description: request_body['description']
    }
    appointments << new_appointment
    status 201
    new_appointment.to_json
  else
    halt 400, { message: 'Invalid appointment data' }.to_json
  end
end

# Route untuk memperbarui janji temu (PUT /appointments/:id)
put '/appointments/:id' do
  content_type :json
  appointment = find_appointment(appointments, params['id'].to_i)

  if appointment
    request_body = JSON.parse(request.body.read)
    appointment[:date] = request_body['date'] if request_body['date']
    appointment[:time] = request_body['time'] if request_body['time']
    appointment[:description] = request_body['description'] if request_body['description']
    appointment.to_json
  else
    halt 404, { message: 'Appointment not found' }.to_json
  end
end

# Route untuk menghapus janji temu (DELETE /appointments/:id)
delete '/appointments/:id' do
  content_type :json
  appointment = find_appointment(appointments, params['id'].to_i)

  if appointment
    appointments.delete(appointment)
    status 204
  else
    halt 404, { message: 'Appointment not found' }.to_json
  end
end

# Route untuk melihat janji temu dalam tampilan HTML (GET /appointments-view)
get '/appointments-view' do
  @appointments = appointments
  @patients = patients
  @doctors = doctors
  erb :appointments_index
end

# Halaman utama default ke daftar janji temu
get '/' do
  redirect '/appointments-view'
end

__END__

@@appointments_index
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Daftar Janji Temu</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      margin: 40px;
    }
    h1 {
      text-align: center;
    }
    table {
      width: 100%;
      border-collapse: collapse;
      margin-bottom: 20px;
    }
    table, th, td {
      border: 1px solid black;
    }
    th, td {
      padding: 10px;
      text-align: left;
    }
    th {
      background-color: #f2f2f2;
    }
    .add-appointment {
      display: block;
      width: 200px;
      margin: 20px auto;
      text-align: center;
      background-color: #4CAF50;
      color: white;
      padding: 10px;
      text-decoration: none;
      border-radius: 5px;
    }
    .add-appointment:hover {
      background-color: #45a049;
    }
  </style>
</head>
<body>
  <h1>Daftar Janji Temu</h1>
  <table>
    <tr>
      <th>ID</th>
      <th>Nama Pasien</th>
      <th>Nama Dokter</th>
      <th>Tanggal</th>
      <th>Waktu</th>
      <th>Deskripsi</th>
    </tr>
    <% @appointments.each do |appointment| %>
      <tr>
        <td><%= appointment[:id] %></td>
        <td><%= @patients.find { |p| p[:id] == appointment[:patient_id] }[:name] %></td>
        <td><%= @doctors.find { |d| d[:id] == appointment[:doctor_id] }[:name] %></td>
        <td><%= appointment[:date] %></td>
        <td><%= appointment[:time] %></td>
        <td><%= appointment[:description] %></td>
      </tr>
    <% end %>
  </table>
  <a href="#" class="add-appointment">Tambah Janji Temu Baru</a>
</body>
</html>
