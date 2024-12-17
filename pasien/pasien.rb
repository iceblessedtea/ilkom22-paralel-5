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