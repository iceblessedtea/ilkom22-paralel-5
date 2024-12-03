class PasienController
  def self.index
    Pasien.all
  end

  def self.create(params)
    Pasien.create(nama: params[:nama], umur: params[:umur], username: params[:username], password: params[:password])
  end

  def self.login(username, password)
    pasien = Pasien.find_by_username(username)
    return nil unless pasien

    if BCrypt::Password.new(pasien.password) == password
      pasien
    else
      nil
    end
  end
end
