require 'bcrypt'

class Pasien
  attr_accessor :id, :nama, :umur, :username, :password

  def initialize(attributes = {})
    @id = attributes[:id]
    @nama = attributes[:nama]
    @umur = attributes[:umur]
    @username = attributes[:username]
    @password = attributes[:password]
  end

  def self.all
    Database.connection.execute('SELECT * FROM pasiens').map do |row|
      Pasien.new(id: row[0], nama: row[1], umur: row[2], username: row[3], password: row[4])
    end
  end

  def self.find_by_username(username)
    row = Database.connection.get_first_row('SELECT * FROM pasiens WHERE username = ?', username)
    row ? Pasien.new(id: row[0], nama: row[1], umur: row[2], username: row[3], password: row[4]) : nil
  end

  def self.create(attributes)
    hashed_password = BCrypt::Password.create(attributes[:password])
    Database.connection.execute('INSERT INTO pasiens (nama, umur, username, password) VALUES (?, ?, ?, ?)',
                                attributes[:nama], attributes[:umur], attributes[:username], hashed_password)
  end
end
