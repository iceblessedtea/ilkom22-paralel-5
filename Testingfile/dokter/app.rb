# app.rb
require 'sinatra'
require 'json'

# In-memory database (array) untuk menyimpan data dokter
doctors = [
  { id: 1, name: "Dr. John Smith", specialization: "Kardiologi", years_of_experience: 10, working_since: "2014" },
  { id: 2, name: "Dr. Emily Johnson", specialization: "Pediatri", years_of_experience: 15, working_since: "2009" }
]

# Helper method untuk mencari dokter berdasarkan ID
def find_doctor(doctors, id)
  doctors.find { |doctor| doctor[:id] == id }
end

# Route untuk menampilkan daftar dokter dalam HTML (GET /doctors-view)
get '/doctors-view' do
  @doctors = doctors
  erb :doctors_index
end

# Route untuk mendapatkan semua dokter (GET /doctors)
get '/doctors' do
  content_type :json
  doctors.to_json
end

# Route untuk mendapatkan dokter berdasarkan ID (GET /doctors/:id)
get '/doctors/:id' do
  content_type :json
  doctor = find_doctor(doctors, params['id'].to_i)

  if doctor
    doctor.to_json
  else
    halt 404, { message: 'Doctor not found' }.to_json
  end
end

# Route untuk menambahkan dokter baru (POST /doctors)
post '/doctors' do
  content_type :json
  request_body = JSON.parse(request.body.read)

  # Validasi sederhana
  if request_body['name'] && request_body['specialization'] && request_body['years_of_experience'] && request_body['working_since']
    new_id = doctors.last[:id] + 1
    new_doctor = {
      id: new_id,
      name: request_body['name'],
      specialization: request_body['specialization'],
      years_of_experience: request_body['years_of_experience'],
      working_since: request_body['working_since']
    }
    doctors << new_doctor
    status 201
    new_doctor.to_json
  else
    halt 400, { message: 'Invalid doctor data' }.to_json
  end
end

# Route untuk memperbarui data dokter (PUT /doctors/:id)
put '/doctors/:id' do
  content_type :json
  doctor = find_doctor(doctors, params['id'].to_i)

  if doctor
    request_body = JSON.parse(request.body.read)
    doctor[:name] = request_body['name'] if request_body['name']
    doctor[:specialization] = request_body['specialization'] if request_body['specialization']
    doctor[:years_of_experience] = request_body['years_of_experience'] if request_body['years_of_experience']
    doctor[:working_since] = request_body['working_since'] if request_body['working_since']
    doctor.to_json
  else
    halt 404, { message: 'Doctor not found' }.to_json
  end
end

# Route untuk menghapus dokter berdasarkan ID (DELETE /doctors/:id)
delete '/doctors/:id' do
  content_type :json
  doctor = find_doctor(doctors, params['id'].to_i)

  if doctor
    doctors.delete(doctor)
    status 204
  else
    halt 404, { message: 'Doctor not found' }.to_json
  end
end

# Route untuk menampilkan daftar pasien dalam HTML (GET /patients-view)
get '/patients-view' do
  @patients = patients
  erb :patients_index
end

# Route default untuk tampilan halaman utama (di-redirect ke /doctors-view)
get '/' do
  redirect '/doctors-view'
end

__END__

@@doctors_index
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Daftar Dokter</title>
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
    .add-doctor {
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
    .add-doctor:hover {
      background-color: #45a049;
    }
  </style>
</head>
<body>
  <h1>Daftar Dokter Rumah Sakit</h1>
  <table>
    <tr>
      <th>ID</th>
      <th>Nama</th>
      <th>Spesialisasi</th>
      <th>Pengalaman (tahun)</th>
      <th>Bekerja Sejak</th>
    </tr>
    <% @doctors.each do |doctor| %>
      <tr>
        <td><%= doctor[:id] %></td>
        <td><%= doctor[:name] %></td>
        <td><%= doctor[:specialization] %></td>
        <td><%= doctor[:years_of_experience] %></td>
        <td><%= doctor[:working_since] %></td>
      </tr>
    <% end %>
  </table>
  <a href="#" class="add-doctor">Tambah Dokter Baru</a>
</body>
</html>
