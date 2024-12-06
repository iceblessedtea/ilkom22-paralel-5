class DokterController
  def self.index
    Dokter.all
  end

  def self.show(id)
    Dokter[id]
  end

  def self.create(params)
    Dokter.create(params)
  end

  def self.update(id, params)
    dokter = Dokter[id]
    dokter.update(params) if dokter
    dokter
  end

  def self.delete(id)
    dokter = Dokter[id]
    dokter.destroy if dokter
  end
end
