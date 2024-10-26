begin
    require_relative 'app/api'
  rescue LoadError => e
    puts "Error loading file: #{e.message}"
  end
  run JanjiTemu::API.new
  