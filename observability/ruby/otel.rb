# frozen_string_literal: true

require "opentelemetry/sdk"
begin
  require "opentelemetry-exporter-otlp"
rescue LoadError
  require "opentelemetry/exporter/otlp"
end
require "opentelemetry/instrumentation/all"

service_name = ENV.fetch("OTEL_SERVICE_NAME", File.basename(Dir.pwd))
service_version = ENV.fetch("OTEL_SERVICE_VERSION", "0.1.0")

ENV["OTEL_TRACES_EXPORTER"] ||= "otlp"
ENV["OTEL_METRICS_EXPORTER"] ||= "none"
ENV["OTEL_LOGS_EXPORTER"] ||= "none"

OpenTelemetry::SDK.configure do |config|
  config.service_name = service_name
  config.service_version = service_version
  config.use_all
end
