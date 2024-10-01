# app.rb
require 'sinatra'
require 'json'

# In-memory database (array) untuk menyimpan data pasien
patients = [
  { id: 1, name: "John Doe", age: 30, disease: "Demam", admitted_on: "2024-09-25" },
  { id: 2, name: "Jane Smith", age: 45, disease: "Hipertensi", admitted_on: "2024-09-26" }
]

# Helper method untuk mencari pasien berdasarkan ID
def find_patient(patients, id)
  patients.find { |patient| patient[:id] == id }
end

# Route untuk tampilan HTML sederhana (GET /patients-view)
get '/patients-view' do
  @patients = patients
  erb :index
end

# Route untuk mendapatkan daftar semua pasien (GET /patients)
get '/patients' do
  content_type :json
  patients.to_json
end

# Route untuk mendapatkan data pasien berdasarkan ID (GET /patients/:id)
get '/patients/:id' do
  content_type :json
  patient = find_patient(patients, params['id'].to_i)

  if patient
    patient.to_json
  else
    halt 404, { message: 'Patient not found' }.to_json
  end
end

# Route untuk menambahkan pasien baru (POST /patients)
post '/patients' do
  content_type :json
  request_body = JSON.parse(request.body.read)

  # Validasi sederhana
  if request_body['name'] && request_body['age'] && request_body['disease'] && request_body['admitted_on']
    new_id = patients.last[:id] + 1
    new_patient = {
      id: new_id,
      name: request_body['name'],
      age: request_body['age'],
      disease: request_body['disease'],
      admitted_on: request_body['admitted_on']
    }
    patients << new_patient
    status 201
    new_patient.to_json
  else
    halt 400, { message: 'Invalid patient data' }.to_json
  end
end

# Route untuk memperbarui data pasien (PUT /patients/:id)
put '/patients/:id' do
  content_type :json
  patient = find_patient(patients, params['id'].to_i)

  if patient
    request_body = JSON.parse(request.body.read)
    patient[:name] = request_body['name'] if request_body['name']
    patient[:age] = request_body['age'] if request_body['age']
    patient[:disease] = request_body['disease'] if request_body['disease']
    patient[:admitted_on] = request_body['admitted_on'] if request_body['admitted_on']
    patient.to_json
  else
    halt 404, { message: 'Patient not found' }.to_json
  end
end

# Route untuk menghapus pasien (DELETE /patients/:id)
delete '/patients/:id' do
  content_type :json
  patient = find_patient(patients, params['id'].to_i)

  if patient
    patients.delete(patient)
    status 204
  else
    halt 404, { message: 'Patient not found' }.to_json
  end
end

# Route default untuk tampilan halaman utama
get '/' do
  redirect '/patients-view'
end

__END__

@@index
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Daftar Pasien</title>
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
    .add-patient {
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
    .add-patient:hover {
      background-color: #45a049;
    }
  </style>
</head>
<body>
  <h1>Daftar Pasien Rumah Sakit</h1>
  <table>
    <tr>
      <th>ID</th>
      <th>Nama</th>
      <th>Umur</th>
      <th>Penyakit</th>
      <th>Tanggal Masuk</th>
    </tr>
    <% @patients.each do |patient| %>
      <tr>
        <td><%= patient[:id] %></td>
        <td><%= patient[:name] %></td>
        <td><%= patient[:age] %></td>
        <td><%= patient[:disease] %></td>
        <td><%= patient[:admitted_on] %></td>
      </tr>
    <% end %>
  </table>
  <a href="#" class="add-patient">Tambah Pasien Baru</a>
</body>
</html>
