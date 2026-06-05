# frozen_string_literal: true

require "opentelemetry/sdk"
require "opentelemetry/exporter/otlp"
require "opentelemetry/instrumentation/all"

service_name = ENV.fetch("OTEL_SERVICE_NAME", File.basename(Dir.pwd))
service_version = ENV.fetch("OTEL_SERVICE_VERSION", "0.1.0")

OpenTelemetry::SDK.configure do |config|
  config.service_name = service_name
  config.service_version = service_version
  config.use_all
end

