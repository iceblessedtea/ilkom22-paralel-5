require 'sinatra'
require 'json'
require 'time'
require 'net/http'
require 'uri'
require 'sequel'
require 'httpx'

module PatientService
  class API < Sinatra::Base
    DB = Sequel.connect('sqlite://db/patients.db')
    REKAM_MEDIK_SERVICE_URL = "http://localhost:7863" # URL Service Rekam Medik
    DOCTOR_SERVICE_URL = "http://localhost:7861"

    # Endpoint root untuk memastikan service berjalan
    get "/" do
      content_type :json
      { message: "Service pasien berjalan dengan baik" }.to_json
    end

    # Mendapatkan semua data pasien
    get "/patients" do
      patients = DB[:patients].all
      content_type :json
      { success: true, patients: patients }.to_json
    end
    # mengambil data jadwal dokter
    get "/schedules" do
      begin
        # Fetch schedules, doctors, timeslots, and rooms data from respective endpoints
        schedules_response = HTTPX.get("#{DOCTOR_SERVICE_URL}/schedules")
        doctors_response = HTTPX.get("#{DOCTOR_SERVICE_URL}/doctors")
        timeslots_response = HTTPX.get("#{DOCTOR_SERVICE_URL}/timeslots")
        rooms_response = HTTPX.get("#{DOCTOR_SERVICE_URL}/rooms")
      
        # Check if all responses are successful
        if schedules_response.status == 200 && 
           doctors_response.status == 200 &&
           timeslots_response.status == 200 &&
           rooms_response.status == 200
      
          # Parse the JSON responses
          schedules = JSON.parse(schedules_response.body.to_s)
          doctors = JSON.parse(doctors_response.body.to_s)
          timeslots = JSON.parse(timeslots_response.body.to_s)
          rooms = JSON.parse(rooms_response.body.to_s)
      
          # Combine schedules with corresponding doctor, timeslot, and room information
          doc_schedules = schedules.map do |schedule|
            doctor = doctors.find { |doc| doc["id"] == schedule["doctor_id"] }
            timeslot = timeslots.find { |ts| ts["id"] == schedule["timeslot_id"] }
            room = rooms.find { |r| r["id"] == schedule["room_id"] }
      
            {
              # schedule_id: schedule["id"],
              # doctor_id: schedule["doctor_id"],
              doctor_name: doctor ? doctor["name"] : "Unknown Doctor",
              # room_id: schedule["room_id"],
              room_name: room ? room["name"] : "Unknown Room",
              # timeslot_id: schedule["timeslot_id"],
              timeslot_day: timeslot ? timeslot["day"] : "Unknown Day",
              timeslot_start_time: timeslot ? timeslot["start_time"] : "Unknown Start Time",
              timeslot_end_time: timeslot ? timeslot["end_time"] : "Unknown End Time"
              # date: schedule["date"]
            }
          end
      
          # Return the combined data as JSON
          content_type :json
          doc_schedules.to_json
        else
          status 500
          { error: "Failed to fetch schedules, doctors, timeslots, or rooms data" }.to_json
        end
      rescue => e
        status 500
        { error: "An error occurred: #{e.message}" }.to_json
      end
    end
   
    post '/patients' do
      begin
        patients_data = JSON.parse(request.body.read)
    
        # Validasi apakah data yang dikirimkan adalah array dan tidak kosong
        if !patients_data.is_a?(Array) || patients_data.empty?
          status 400
          return { error: "Data harus dalam bentuk array dan tidak boleh kosong." }.to_json
        end
    
        # Loop melalui setiap pasien dan masukkan ke database
        patients_data.each do |patient_data|
          # Validasi field pasien
          if patient_data["name"].nil? || patient_data["age"].nil? || patient_data["gender"].nil? || patient_data["address"].nil?
            status 400
            return { error: "Semua field (name, age, gender, address) wajib diisi." }.to_json
          end
    
          # Masukkan data pasien ke database
          DB[:patients].insert(
            name: patient_data["name"],
            age: patient_data["age"].to_i,
            gender: patient_data["gender"],
            address: patient_data["address"],
            created_at: Time.now,
            updated_at: Time.now
          )
        end
    
        # Jika berhasil menambahkan pasien
        status 201
        { success: true, message: "Data pasien berhasil ditambahkan." }.to_json
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue StandardError => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end
    
    # Mendapatkan data pasien berdasarkan ID
    get '/patients/:id' do
      patient = DB[:patients].where(id: params['id'].to_i).first

      if patient
        content_type :json
        { success: true, patient: patient }.to_json
      else
        status 404
        { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    # Endpoint untuk melihat pasien dengan rekam medisnya
    get '/patients/:id/records' do
      patient = DB[:patients].where(id: params['id'].to_i).first

      if patient
        # Fetch rekam medik dari Service Rekam Medik
        uri = URI("#{REKAM_MEDIK_SERVICE_URL}/medical_records/#{patient[:id]}")
        response = Net::HTTP.get_response(uri)

        if response.is_a?(Net::HTTPSuccess)
          medical_record = JSON.parse(response.body)

          # Gabungkan data pasien dengan data rekam medik
          result = {
            id: patient[:id],
            name: patient[:name],
            age: patient[:age],
            gender: patient[:gender],   # Menampilkan gender
            address: patient[:address], # Menampilkan address
            medical_record: medical_record
          }

          content_type :json
          { success: true, data: result }.to_json
        else
          status response.code.to_i
          { error: "Gagal mengambil data rekam medik untuk pasien ID #{patient[:id]}" }.to_json
        end
      else
        status 404
        { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
      put '/patients/:id' do
        begin
          patient_data = JSON.parse(request.body.read)
      
          # Validasi apakah data pasien yang diterima lengkap
          if patient_data["name"].nil? || patient_data["age"].nil? || patient_data["gender"].nil? || patient_data["address"].nil?
            status 400
            return { error: "Semua field (name, age, gender, address) wajib diisi." }.to_json
          end
      
          # Cari pasien berdasarkan ID
          patient = DB[:patients].where(id: params['id'].to_i).first
      
          if patient
            # Perbarui data pasien
            DB[:patients].where(id: params['id'].to_i).update(
              name: patient_data["name"],
              age: patient_data["age"].to_i,
              gender: patient_data["gender"],
              address: patient_data["address"],
              updated_at: Time.now
            )
            # Kembalikan response sukses
            content_type :json
            { success: true, message: "Data pasien berhasil diperbarui." }.to_json
          else
            # Pasien tidak ditemukan
            status 404
            { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
          end
        rescue JSON::ParserError => e
          status 400
          { error: "Invalid JSON payload: #{e.message}" }.to_json
        rescue StandardError => e
          status 500
          { error: "Terjadi kesalahan: #{e.message}" }.to_json
        end
      end
    end
  end
end
