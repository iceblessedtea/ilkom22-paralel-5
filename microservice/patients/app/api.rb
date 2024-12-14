# require 'sinatra'
# require 'json'
# require 'time'
# require 'net/http'
# require 'uri'
# require 'sequel'

# module PatientService
#   class API < Sinatra::Base
#     DB = Sequel.connect('sqlite://D:/KULIAH/KOMPUTASI%20PARALEL%20TERDISTRIBUSI/ilkom22-paralel-5/microservice/patients/db/patients.db')
#     REKAM_MEDIK_SERVICE_URL = "http://localhost:7863" # URL Service Rekam Medik

#     # Endpoint root untuk memastikan service berjalan
#     get "/" do
#       content_type :json
#       { message: "Service pasien berjalan dengan baik" }.to_json
#     end

#     # Mendapatkan semua data pasien
#     get "/patients" do
#       patients = DB[:patients].all
#       content_type :json
#       patients.to_json
#     end

#     # Menambahkan data pasien
#     post '/patients' do
#       begin
#         patient_data = JSON.parse(request.body.read)

#         # Masukkan data pasien ke database
#         new_patient = DB[:patients].insert(
#           name: patient_data["name"],
#           age: patient_data["age"],
#           gender: patient_data["gender"],
#           address: patient_data["address"],
#           created_at: Time.now,
#           updated_at: Time.now
#         )

#         status 201
#         { success: true, patient_id: new_patient }.to_json
#       rescue JSON::ParserError => e
#         status 400
#         { error: "Invalid JSON payload: #{e.message}" }.to_json
#       rescue StandardError => e
#         status 500
#         { error: "Terjadi kesalahan: #{e.message}" }.to_json
#       end
#     end

#     # Mendapatkan data pasien berdasarkan ID
#     get '/patients/:id' do
#       patient = DB[:patients].where(id: params['id'].to_i).first

#       if patient
#         content_type :json
#         patient.to_json
#       else
#         status 404
#         { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
#       end
#     end

#     # Endpoint untuk melihat pasien dengan rekam medisnya
#     get '/patients/:id/records' do
#       patient = DB[:patients].where(id: params['id'].to_i).first

#       if patient
#         # Fetch rekam medik dari Service Rekam Medik
#         uri = URI("#{REKAM_MEDIK_SERVICE_URL}/medical_records/#{patient[:id]}")
#         response = Net::HTTP.get_response(uri)

#         if response.is_a?(Net::HTTPSuccess)
#           medical_record = JSON.parse(response.body)

#           # Gabungkan data pasien dengan data rekam medik
#           result = {
#             id: patient[:id],
#             name: patient[:name],
#             age: patient[:age],
#             gender: patient[:gender],   # Menampilkan gender
#             address: patient[:address], # Menampilkan address
#             medical_record: medical_record
#           }

#           content_type :json
#           result.to_json
#         else
#           status response.code.to_i
#           { error: "Gagal mengambil data rekam medik untuk pasien ID #{patient[:id]}" }.to_json
#         end
#       else
#         status 404
#         { error: "Patient dengan ID #{params['id']} tidak ditemukan" }.to_json
#       end
#     end
#   end
# end
require 'sinatra'
require 'json'
require 'time'
require 'net/http'
require 'uri'
require 'sequel'

module PatientService
  class API < Sinatra::Base
    DB = Sequel.connect('sqlite://db/patients.db')
    REKAM_MEDIK_SERVICE_URL = "http://localhost:7863" # URL Service Rekam Medik

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

    # Menambahkan data pasien
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
    # post '/patients' do
    #   begin
    #     patient_data = JSON.parse(request.body.read)

    #     # Validasi input
    #     if patient_data["name"].nil? || patient_data["age"].nil? || patient_data["gender"].nil? || patient_data["address"].nil?
    #       status 400
    #       return { error: "Semua field (name, age, gender, address) wajib diisi." }.to_json
    #     end

    #     # Masukkan data pasien ke database
    #     new_patient_id = DB[:patients].insert(
    #       name: patient_data["name"],
    #       age: patient_data["age"].to_i,
    #       gender: patient_data["gender"],
    #       address: patient_data["address"],
    #       created_at: Time.now,
    #       updated_at: Time.now
    #     )

    #     status 201
    #     { success: true, patient_id: new_patient_id }.to_json
    #   rescue JSON::ParserError => e
    #     status 400
    #     { error: "Invalid JSON payload: #{e.message}" }.to_json
    #   rescue StandardError => e
    #     status 500
    #     { error: "Terjadi kesalahan: #{e.message}" }.to_json
    #   end
    # end

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
    end
  end
end
