require 'sinatra'
require 'json'
require 'time'

module DoctorService
  class API < Sinatra::Base
    # Data dokter dummy
    DOCTORS = [
      { id: 1, name: "Dr. Smith", specialization: "Cardiology", created_at: Time.now, updated_at: Time.now },
      { id: 2, name: "Dr. Jane", specialization: "Dermatology", created_at: Time.now, updated_at: Time.now }
    ]

    get "/" do
      content_type :json
      { message: "Service doctor berjalan dengan baik", doctors: DOCTORS }.to_json
    end

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

    get '/doctors/:id' do
      doctor = DOCTORS.find { |d| d[:id] == params['id'].to_i }

      if doctor
        content_type :json
        doctor.to_json
      else
        status 404
        { error: "Doctor dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end
  end
end
