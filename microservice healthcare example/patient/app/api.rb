require 'Sinatra'
require 'json'

module HealthService
  class Patient < Sinatra::Base
    get '/' do
      content_type :json
      {message: "Selamat Datang :)"}.to_json
    end

    get '/patient' do
      patients = [
        {"id" => 1, "name" => "Putri Eka Wulandari"},
        {"id" => 2, "name" => "Deswita Maharani"},
        {"id" => 3, "name" => "Khusnul Qhatimah Khamaisyah"}
      ]
      content_type :json
      {'succes' => true, 'data' => patients}.to_json
    end

    # Menampilkan data patient berdasarkan id
    get '/patient/:id' do
      content_type :json
      patient = patients.find {|pt| pt[:id] == params[:id].to_i}
      if patient
        patient.to_json
      else
        {mesaage: "pasien tidak ditemukan"}.to_json
      end
    end
    
    #CRUD PATIENT
    get '/patient' do
      p arr_patients
    end

    post '/patient' do
      patients.save
    end

    #CRUD QUEUE
    get '/queue' do
      p arr_queue
    end

    post '/queue' do
      queue.save(req.body)
    end

  end
end
  
