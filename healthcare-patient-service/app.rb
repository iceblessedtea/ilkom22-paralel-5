# app.rb
require 'sinatra'
require 'json'

# Simulasi database pasien dalam bentuk array
patients = [
  { id: 1, name: 'dhany', age: 21 , address: 'bombana', phone: '081222331122' },
  { id: 2, name: 'ramadhan', age: 22, address: 'surabaya', phone: '0878854632345'}
]

# Endpoint untuk menampilkan daftar pasien
get '/patients' do
  content_type :json
  patients.to_json
end

# Endpoint untuk menambahkan pasien baru
post '/patients' do
  content_type :json
  new_patient = {
    id: patients.size + 1,
    name: params[:name],
    age: params[:age].to_i,
    address: params[:address],
    phone: params[:phone]
  }
  patients << new_patient
  new_patient.to_json
end

# Endpoint untuk mendapatkan detail pasien berdasarkan ID
get '/patients/:id' do
  content_type :json
  patient = patients.find { |p| p[:id] == params[:id].to_i }
  # Mengembalikan error 404 jika pasien tidak ditemukan
  halt(404, { error: 'Patient not found' }.to_json) unless patient
  patient.to_json
end

# Endpoint untuk memperbarui data pasien berdasarkan ID
put '/patients/:id' do
  content_type :json
  patient = patients.find { |p| p[:id] == params[:id].to_i }
  halt(404, { error: 'Patient not found' }.to_json) unless patient

  # Memperbarui data pasien dengan atribut tambahan
  patient[:name] = params[:name] if params[:name]
  patient[:age] = params[:age].to_i if params[:age]
  patient[:address] = params[:address] if params[:address]
  patient[:phone] = params[:phone] if params[:phone]

  patient.to_json
end
