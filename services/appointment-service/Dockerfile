# Base image
FROM ruby:3.3.5

# Set working directory
WORKDIR /app

# Copy files
COPY . .

# Install dependencies
RUN bundle install

# Ekspose port yang digunakan oleh aplikasi
EXPOSE 7862

# Run the service
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "7862"]
