class RekamMedik
  def self.create(dokter_id, pasien_id, catatan)
    DB.execute('INSERT INTO rekam_medik (dokter_id, pasien_id, catatan) VALUES (?, ?, ?)', dokter_id, pasien_id, catatan)
  end

  def self.all
    DB.execute('SELECT * FROM rekam_medik WHERE deleted_at IS NULL')
  end

  def self.find(id)
    DB.execute('SELECT * FROM rekam_medik WHERE id = ? AND deleted_at IS NULL', id).first
  end

  def self.update(id, dokter_id, pasien_id, catatan)
    DB.execute('UPDATE rekam_medik SET dokter_id = ?, pasien_id = ?, catatan = ? WHERE id = ?', dokter_id, pasien_id, catatan, id)
  end

  def self.soft_delete(id)
    DB.execute('UPDATE rekam_medik SET deleted_at = ? WHERE id = ?', Time.now, id)
  end
end
