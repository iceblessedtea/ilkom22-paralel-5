param(
  [switch]$WithOtel
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

$env:PATIENT_URL = "http://localhost:7860"
$env:DOCTOR_URL = "http://localhost:7861"
$env:APPOINTMENT_URL = "http://localhost:7862"
$env:MEDICAL_RECORD_URL = "http://localhost:7863"

if ($WithOtel) {
  $env:OTEL_ENABLED = "true"
  $env:OTEL_EXPORTER_OTLP_ENDPOINT = "http://localhost:4318"
} else {
  $env:OTEL_ENABLED = "false"
}

$services = @(
  @{ Name = "patient-service"; Port = 7860; Database = "patient_service" },
  @{ Name = "doctor-service"; Port = 7861; Database = "doctor_service" },
  @{ Name = "appointment-service"; Port = 7862; Database = "appointment_service" },
  @{ Name = "medical-record-service"; Port = 7863; Database = "medical_record_service" }
)

foreach ($service in $services) {
  $servicePath = Join-Path $root $service.Name
  $command = @"
`$env:PATIENT_URL='$env:PATIENT_URL'
`$env:DOCTOR_URL='$env:DOCTOR_URL'
`$env:APPOINTMENT_URL='$env:APPOINTMENT_URL'
`$env:MEDICAL_RECORD_URL='$env:MEDICAL_RECORD_URL'
`$env:DATABASE_URL='postgres://healthcare:healthcare@localhost:5432/$($service.Database)'
`$env:OTEL_ENABLED='$env:OTEL_ENABLED'
`$env:OTEL_SERVICE_NAME='$($service.Name)'
`$env:OTEL_EXPORTER_OTLP_ENDPOINT='$env:OTEL_EXPORTER_OTLP_ENDPOINT'
Set-Location '$servicePath'
bundle install
bundle exec ruby db/migrate.rb
bundle exec rackup --host 0.0.0.0 --port $($service.Port)
"@

  Start-Process powershell -ArgumentList "-NoExit", "-Command", $command
}

Write-Host "Started local microservices. Use -WithOtel to enable OpenTelemetry env variables."
