require 'sinatra'
require 'json'
require 'time'
require 'net/http'
require 'sequel'

module DoctorService
  class API < Sinatra::Base
    DB = Sequel.connect('sqlite://db/doctors.db')

    APPOINTMENT_SERVICE_URL = 'http://appointments:7862'

    # Route Home
    get '/' do
      content_type :json
      { message: "Service doctor is up"}.to_json
    end

    # Routes for Doctors
    get '/doctors' do
      doctors = DB[:doctors].all
      content_type :json
      doctors.to_json
    end

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

    delete '/doctors/:id' do
      doctor = DB[:doctors].where(id: params['id'].to_i).first

      if doctor
        begin
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

    # Routes for Rooms
    get '/rooms' do
      rooms = DB[:rooms].all
      content_type :json
      rooms.to_json
    end

    get '/rooms/:id' do
      room = DB[:rooms].where(id: params['id'].to_i).first

      if room
        content_type :json
        room.to_json
      else
        status 404
        { error: "Room dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    post '/rooms' do
      begin
        room_data = JSON.parse(request.body.read)
        id = DB[:rooms].insert(
          name: room_data["name"],
          created_at: Time.now,
          updated_at: Time.now
        )

        status 201
        { success: true, room_id: id }.to_json
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    put '/rooms/:id' do
      begin
        room = DB[:rooms].where(id: params['id'].to_i).first

        if room
          room_data = JSON.parse(request.body.read)
          DB[:rooms].where(id: params['id'].to_i).update(
            name: room_data["name"] || room[:name],
            updated_at: Time.now
          )

          updated_room = DB[:rooms].where(id: params['id'].to_i).first
          status 200
          { success: true, room: updated_room }.to_json
        else
          status 404
          { error: "Room dengan ID #{params['id']} tidak ditemukan" }.to_json
        end
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    delete '/rooms/:id' do
      room = DB[:rooms].where(id: params['id'].to_i).first

      if room
        DB[:rooms].where(id: params['id'].to_i).delete
        status 200
        { success: true, message: "Room dengan ID #{params['id']} berhasil dihapus" }.to_json
      else
        status 404
        { error: "Room dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    # Routes for Timeslots
    get '/timeslots' do
      timeslots = DB[:timeslots].all
      content_type :json
      timeslots.to_json
    end

    get '/timeslots/:id' do
      timeslot = DB[:timeslots].where(id: params['id'].to_i).first

      if timeslot
        content_type :json
        timeslot.to_json
      else
        status 404
        { error: "Timeslot dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    post '/timeslots' do
      begin
        timeslot_data = JSON.parse(request.body.read)
        id = DB[:timeslots].insert(
          day: timeslot_data["day"],
          start_time: timeslot_data["start_time"],
          end_time: timeslot_data["end_time"],
          created_at: Time.now,
          updated_at: Time.now
        )

        status 201
        { success: true, timeslot_id: id }.to_json
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    put '/timeslots/:id' do
      begin
        timeslot = DB[:timeslots].where(id: params['id'].to_i).first

        if timeslot
          timeslot_data = JSON.parse(request.body.read)
          DB[:timeslots].where(id: params['id'].to_i).update(
            day: timeslot_data["day"] || timeslot[:day],
            start_time: timeslot_data["start_time"] || timeslot[:start_time],
            end_time: timeslot_data["end_time"] || timeslot[:end_time],
            updated_at: Time.now
          )

          updated_timeslot = DB[:timeslots].where(id: params['id'].to_i).first
          status 200
          { success: true, timeslot: updated_timeslot }.to_json
        else
          status 404
          { error: "Timeslot dengan ID #{params['id']} tidak ditemukan" }.to_json
        end
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    delete '/timeslots/:id' do
      timeslot = DB[:timeslots].where(id: params['id'].to_i).first

      if timeslot
        DB[:timeslots].where(id: params['id'].to_i).delete
        status 200
        { success: true, message: "Timeslot dengan ID #{params['id']} berhasil dihapus" }.to_json
      else
        status 404
        { error: "Timeslot dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    # Routes for Schedules
    get '/schedules' do
      schedules = DB[:schedules].all
      content_type :json
      schedules.to_json
    end

    get '/schedules/:id' do
      schedule = DB[:schedules].where(id: params['id'].to_i).first

      if schedule
        content_type :json
        schedule.to_json
      else
        status 404
        { error: "Schedule dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end

    post '/schedules' do
      begin
        schedule_data = JSON.parse(request.body.read)
        id = DB[:schedules].insert(
          room_id: schedule_data["room_id"],
          timeslot_id: schedule_data["timeslot_id"],
          doctor_id: schedule_data["doctor_id"],
          date: schedule_data["date"],
          created_at: Time.now,
          updated_at: Time.now
        )

        status 201
        { success: true, schedule_id: id }.to_json
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    put '/schedules/:id' do
      begin
        schedule = DB[:schedules].where(id: params['id'].to_i).first

        if schedule
          schedule_data = JSON.parse(request.body.read)
          DB[:schedules].where(id: params['id'].to_i).update(
            room_id: schedule_data["room_id"] || schedule[:room_id],
            timeslot_id: schedule_data["timeslot_id"] || schedule[:timeslot_id],
            doctor_id: schedule_data["doctor_id"] || schedule[:doctor_id],
            date: schedule_data["date"] || schedule[:date],
            updated_at: Time.now
          )

          updated_schedule = DB[:schedules].where(id: params['id'].to_i).first
          status 200
          { success: true, schedule: updated_schedule }.to_json
        else
          status 404
          { error: "Schedule dengan ID #{params['id']} tidak ditemukan" }.to_json
        end
      rescue JSON::ParserError => e
        status 400
        { error: "Invalid JSON payload: #{e.message}" }.to_json
      rescue => e
        status 500
        { error: "Terjadi kesalahan: #{e.message}" }.to_json
      end
    end

    delete '/schedules/:id' do
      schedule = DB[:schedules].where(id: params['id'].to_i).first

      if schedule
        DB[:schedules].where(id: params['id'].to_i).delete
        status 200
        { success: true, message: "Schedule dengan ID #{params['id']} berhasil dihapus" }.to_json
      else
        status 404
        { error: "Schedule dengan ID #{params['id']} tidak ditemukan" }.to_json
      end
    end
  end
end
