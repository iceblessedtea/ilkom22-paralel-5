put '/appointments/:id' do
    begin
      appointment_data = JSON.parse(request.body.read)
      puts "Received updated appointment data: #{appointment_data}"
  
      # Check if the appointment exists
      appointment = DB[:appointments].where(id: params['id']).first
      if appointment.nil?
        status 404
        return { error: "Appointment not found" }.to_json
      end
  
      # Prepare data for update
      updated_data = {
        patient_id: appointment_data["patient_id"] || appointment[:patient_id],
        doctor_id: appointment_data["doctor_id"] || appointment[:doctor_id],
        date: appointment_data["date"] || appointment[:date],
        notes: appointment_data["notes"] || appointment[:notes],
        updated_at: Time.now
      }
  
      # Update the appointment
      updated = DB[:appointments].where(id: params['id']).update(updated_data)
  
      if updated > 0
        status 200
        { success: true, appointment_id: params['id'], updated_data: updated_data }.to_json
      else
        status 500
        { error: "Failed to update the appointment" }.to_json
      end
    rescue JSON::ParserError => e
      status 400
      { error: "Invalid JSON payload: #{e.message}" }.to_json
    rescue => e
      status 500
      { error: "Error processing request: #{e.message}" }.to_json
    end
  end