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
    REKAM_MEDIK_SERVICE_URL = "http://medical_records:7863" # URL Service Rekam Medik
    DOCTOR_SERVICE_URL = "http://doctors:7861"

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

    # Menambahkan pasien baru
    post '/patients' do
      begin
        patients_data = JSON.parse(request.body.read)

        unless patients_data.is_a?(Array) && !patients_data.empty?
          halt 400, { error: "Data harus dalam bentuk array dan tidak boleh kosong." }.to_json
        end

        patients_data.each do |patient_data|
          required_fields = %w[name age gender address]
          unless required_fields.all? { |field| patient_data.key?(field) }
            halt 400, { error: "Field #{required_fields.join(', ')} wajib diisi." }.to_json
          end

          DB[:patients].insert(
            name: patient_data["name"],
            age: patient_data["age"].to_i,
            gender: patient_data["gender"],
            address: patient_data["address"],
            created_at: Time.now,
            updated_at: Time.now
          )
        end

        status 201
        { success: true, message: "Data pasien berhasil ditambahkan." }.to_json
      rescue JSON::ParserError => e
        halt 400, { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        halt 500, { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    # Mendapatkan data pasien berdasarkan ID
    get '/patients/:id' do
      patient = DB[:patients].where(id: params['id'].to_i).first

      if patient
        content_type :json
        { success: true, patient: patient }.to_json
      else
        halt 404, { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    # Memperbarui data pasien
    put '/patients/:id' do
      begin
        patient_data = JSON.parse(request.body.read)

        required_fields = %w[name age gender address]
        unless required_fields.all? { |field| patient_data.key?(field) }
          halt 400, { error: "Field #{required_fields.join(', ')} wajib diisi." }.to_json
        end

        patient = DB[:patients].where(id: params['id'].to_i).first

        if patient
          DB[:patients].where(id: params['id'].to_i).update(
            name: patient_data["name"],
            age: patient_data["age"].to_i,
            gender: patient_data["gender"],
            address: patient_data["address"],
            updated_at: Time.now
          )
          { success: true, message: "Data pasien berhasil diperbarui." }.to_json
        else
          halt 404, { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
        end
      rescue JSON::ParserError => e
        halt 400, { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        halt 500, { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    # Mendapatkan data pasien dengan rekam medis
    get '/patients/:id/records' do
      patient = DB[:patients].where(id: params['id'].to_i).first

      if patient
        begin
          uri = URI("#{REKAM_MEDIK_SERVICE_URL}/medical_records/#{patient[:id]}")
          response = Net::HTTP.get_response(uri)

          if response.is_a?(Net::HTTPSuccess)
            medical_record = JSON.parse(response.body)
            result = {
              id: patient[:id],
              name: patient[:name],
              age: patient[:age],
              gender: patient[:gender],
              address: patient[:address],
              medical_record: medical_record
            }
            content_type :json
            { success: true, data: result }.to_json
          else
            halt response.code.to_i, { error: "Gagal mengambil data rekam medik untuk pasien ID #{patient[:id]}" }.to_json
          end
        rescue => e
          halt 500, { error: "Terjadi kesalahan: #{e.message}" }.to_json
        end
      else
        halt 404, { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    get "/schedules" do
      begin
        # Ambil jadwal dari DoctorService
        uri = URI("#{DOCTOR_SERVICE_URL}/schedules")
        response = Net::HTTP.get_response(uri)
    
        if response.is_a?(Net::HTTPSuccess)
          schedules = JSON.parse(response.body)
          detailed_schedules = schedules.map do |schedule|
            # Ambil informasi dokter berdasarkan doctor_id
            doctor_uri = URI("#{DOCTOR_SERVICE_URL}/doctors/#{schedule['doctor_id']}")
            doctor_response = Net::HTTP.get_response(doctor_uri)
            doctor = JSON.parse(doctor_response.body) if doctor_response.is_a?(Net::HTTPSuccess)
    
            # Ambil informasi timeslot berdasarkan timeslot_id
            timeslot_uri = URI("#{DOCTOR_SERVICE_URL}/timeslots/#{schedule['timeslot_id']}")
            timeslot_response = Net::HTTP.get_response(timeslot_uri)
            timeslot = JSON.parse(timeslot_response.body) if timeslot_response.is_a?(Net::HTTPSuccess)
    
            # Ambil informasi ruangan berdasarkan room_id
            room_uri = URI("#{DOCTOR_SERVICE_URL}/rooms/#{schedule['room_id']}")
            room_response = Net::HTTP.get_response(room_uri)
            room = JSON.parse(room_response.body) if room_response.is_a?(Net::HTTPSuccess)
    
            # Gabungkan semua informasi menjadi jadwal yang detil
            {
              schedule_id: schedule['id'],
              doctor_name: doctor ? doctor['name'] : 'Unknown Doctor',
              doctor_specialization: doctor ? doctor['specialization'] : 'Unknown Specialization',
              timeslot_day: timeslot ? timeslot['day'] : 'Unknown Day',
              timeslot_start_time: timeslot ? timeslot['start_time'] : 'Unknown Start Time',
              timeslot_end_time: timeslot ? timeslot['end_time'] : 'Unknown End Time',
              room_name: room ? room['name'] : 'Unknown Room',
              date: schedule['date']
            }
          end
    
          content_type :json
          { success: true, schedules: detailed_schedules }.to_json
        else
          halt 500, { error: "Gagal mengambil jadwal dari DoctorService" }.to_json
        end
      rescue => e
        halt 500, { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end    
  end
end
