# Build stage
FROM ruby:3.0-alpine AS builder

# Install build dependencies
RUN apk add --no-cache build-base

# Set the working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install --without development test

# Copy the rest of the application code
COPY . .

# Remove unnecessary files
RUN rm -rf tmp/* log/* test/ spec/

# Production stage
FROM ruby:3.0-alpine

# Install runtime dependencies
RUN apk add --no-cache tzdata

# Set the working directory
WORKDIR /app

# Copy built artifacts from builder stage
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Set environment variables
ENV RAILS_ENV=production
ENV RACK_ENV=production

# Expose the port the app runs on
EXPOSE 8080

# Start the application
CMD ["bundle", "exec", "ruby", "api.rb"]
CMD ["bundle", "exec", "rackup", "--port=8080"]