require 'sinatra'
require 'json'
require 'time'
require 'net/http'

module DoctorService
  class API < Sinatra::Base
    DOCTORS = [
      { id: 1, name: "Dr. Smith", specialization: "Cardiology", created_at: Time.now, updated_at: Time.now },
      { id: 2, name: "Dr. Jane", specialization: "Dermatology", created_at: Time.now, updated_at: Time.now }
    ]

    APPOINTMENT_SERVICE_URL = 'http://127.0.0.1:7862'

    # Route Home
    get '/' do
      content_type :json
      { message: "Service doctor is up"}.to_json
    end

    # Get Semua Data Doctors
    get '/doctors' do
      content_type :json
      DOCTORS.to_json
    end

    # Get Data Dokter Berdasarkan ID
    get '/doctors/:id' do
      doctor_id = params['id'].to_i
      doctor = DOCTORS.find { |d| d[:id] == doctor_id }

      if doctor
        content_type :json
        doctor.to_json
      else
        status 404
        { error: "Doctor dengan ID #{doctor_id} tidak ditemukan" }.to_json
      end
    end

    # Menambahkan Data Dokter
    post '/doctors' do
      begin
        doctor_data = JSON.parse(request.body.read)
        id = DOCTORS.size + 1

        new_doctor = {
          id: id,
          name: doctor_data["name"],
          specialization: doctor_data["specialization"],
          created_at: Time.now,
          updated_at: Time.now
        }

        DOCTORS << new_doctor

        status 201
        { success: true, doctor_id: id }.to_json
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    # Mengedit Data Dokter
    put '/doctors/:id' do
      begin
        doctor = DOCTORS.find { |d| d[:id] == params['id'].to_i }

        if doctor
          doctor_data = JSON.parse(request.body.read)
          doctor[:name] = doctor_data["name"] if doctor_data["name"]
          doctor[:specialization] = doctor_data["specialization"] if doctor_data["specialization"]
          doctor[:updated_at] = Time.now

          status 200
          { success: true, doctor: doctor }.to_json
        else
          status 404
          { error: "Doctor dengan ID #{params['id']} tidak ditemukan" }.to_json
        end
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    # Menghapus Data Dokter
    delete '/doctors/:id' do
      doctor = DOCTORS.find { |d| d[:id] == params['id'].to_i }

      if doctor
        begin
          # Cek ke service appointment apakah ada appointment terkait dokter ini
          uri = URI("#{APPOINTMENT_SERVICE_URL}/appointments?doctor_id=#{doctor[:id]}")
          response = Net::HTTP.get_response(uri)

          if response.code == '200'
            appointments = JSON.parse(response.body)

            if appointments.empty?
              DOCTORS.delete(doctor)
              status 200
              { success: true, message: "Doctor dengan ID #{params['id']} berhasil dihapus" }.to_json
            else
              status 400
              { error: "Doctor dengan ID #{params['id']} tidak dapat dihapus karena masih memiliki appointment terkait" }.to_json
            end
          else
            status 500
            { error: "Gagal menghubungi service appointment" }.to_json
          end
        rescue => e
          status 500
          { error: "Terjadi kesalahan saat berkomunikasi dengan service appointment: #{e.message}" }.to_json
        end
      else
        status 404
        { error: "Doctor dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end
  end
end
