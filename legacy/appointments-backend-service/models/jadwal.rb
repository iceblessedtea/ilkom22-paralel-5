class Dokter
  def self.create(nama, spesialis, usia)
    DB.execute('INSERT INTO dokters (nama, spesialis, usia) VALUES (?, ?, ?)', nama, spesialis, usia)
  end

  def self.all
    DB.execute('SELECT * FROM dokters')
  end

  def self.find(id)
    DB.execute('SELECT * FROM dokters WHERE id = ?', id).first
  end

  def self.update(id, nama, spesialis, usia)
    DB.execute('UPDATE dokters SET nama = ?, spesialis = ?, usia = ? WHERE id = ?', nama, spesialis, usia, id)
  end

  def self.delete(id)
    DB.execute('DELETE FROM dokters WHERE id = ?', id)
  end
end

