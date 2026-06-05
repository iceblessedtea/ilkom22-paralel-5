if ENV.fetch('OTEL_ENABLED', 'false') == 'true'
  otel_config = File.expand_path('../../observability/ruby/otel', __dir__)
  otel_config = '/observability/ruby/otel' unless File.exist?("#{otel_config}.rb")
  require otel_config
  use(*OpenTelemetry::Instrumentation::Rack::Instrumentation.instance.middleware_args)
end

require_relative 'app/api'
run MedicalRecordService::API.new
