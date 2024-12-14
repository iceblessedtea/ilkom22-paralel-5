require 'sinatra'
require 'json'
require 'time'
require 'net/http'
require 'sequel'

module DoctorService
  class API < Sinatra::Base
    DB = Sequel.connect('sqlite://db/doctors.db')

    APPOINTMENT_SERVICE_URL = 'http://127.0.0.1:7862'

    # Route Home
    get '/' do
      content_type :json
      { message: "Service doctor is up"}.to_json
    end

    # Get Semua Data Doctors
    get '/doctors' do
      doctors = DB[:doctors].all
      content_type :json
      doctors.to_json
    end

    # Get Data Dokter Berdasarkan ID
    get '/doctors/:id' do
      doctor = DB[:doctors].where(id: params['id'].to_i).first

      if doctor
        content_type :json
        doctor.to_json
      else
        status 404
        { error: "Doctor dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    # Menambahkan Data Dokter
    post '/doctors' do
      begin
        doctor_data = JSON.parse(request.body.read)
        id = DB[:doctors].insert(
          name: doctor_data["name"],
          specialization: doctor_data["specialization"],
          created_at: Time.now,
          updated_at: Time.now
        )

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
        doctor = DB[:doctors].where(id: params['id'].to_i).first

        if doctor
          doctor_data = JSON.parse(request.body.read)
          DB[:doctors].where(id: params['id'].to_i).update(
            name: doctor_data["name"] || doctor[:name],
            specialization: doctor_data["specialization"] || doctor[:specialization],
            updated_at: Time.now
          )

          updated_doctor = DB[:doctors].where(id: params['id'].to_i).first
          status 200
          { success: true, doctor: updated_doctor }.to_json
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
      doctor = DB[:doctors].where(id: params['id'].to_i).first

      if doctor
        begin
          # Cek ke service appointment apakah ada appointment terkait dokter ini
          uri = URI("#{APPOINTMENT_SERVICE_URL}/appointments?doctor_id=#{doctor[:id]}")
          response = Net::HTTP.get_response(uri)

          if response.code == '200'
            appointments = JSON.parse(response.body)

            if appointments.empty?
              DB[:doctors].where(id: params['id'].to_i).delete
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
