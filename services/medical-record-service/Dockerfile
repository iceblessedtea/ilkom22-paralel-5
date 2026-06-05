# Gunakan Ruby sebagai base image
FROM ruby:3.3.5

# Set working directory di container
WORKDIR /app

# Salin file ke dalam container
COPY . /app

# Instal dependensi
RUN bundle install

# Ekspose port yang digunakan oleh aplikasi
EXPOSE 7863

# Perintah untuk menjalankan service
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "7863"]
