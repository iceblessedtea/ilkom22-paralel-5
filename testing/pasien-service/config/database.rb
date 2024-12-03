require 'sqlite3'

class Database
  def self.connection
    @db ||= SQLite3::Database.new('db/pasien_service.db')
  end
end
