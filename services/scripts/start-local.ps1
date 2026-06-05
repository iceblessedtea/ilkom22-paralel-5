param(
  [switch]$WithOtel
)

$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot

$env:PATIENT_URL = "http://localhost:7860"
$env:DOCTOR_URL = "http://localhost:7861"
$env:APPOINTMENT_SERVICE_URL = "http://localhost:7862"
$env:REKAM_MEDIK_SERVICE_URL = "http://localhost:7863"

if ($WithOtel) {
  $env:OTEL_ENABLED = "true"
  $env:OTEL_EXPORTER_OTLP_ENDPOINT = "http://localhost:4318"
} else {
  $env:OTEL_ENABLED = "false"
}

$services = @(
  @{ Name = "patient-service"; Port = 7860; OtelName = "patient-service" },
  @{ Name = "doctor-service"; Port = 7861; OtelName = "doctor-service" },
  @{ Name = "appointment-service"; Port = 7862; OtelName = "appointment-service" },
  @{ Name = "medical-record-service"; Port = 7863; OtelName = "medical-record-service" }
)

foreach ($service in $services) {
  $servicePath = Join-Path $root $service.Name
  $command = @"
`$env:PATIENT_URL='$env:PATIENT_URL'
`$env:DOCTOR_URL='$env:DOCTOR_URL'
`$env:APPOINTMENT_SERVICE_URL='$env:APPOINTMENT_SERVICE_URL'
`$env:REKAM_MEDIK_SERVICE_URL='$env:REKAM_MEDIK_SERVICE_URL'
`$env:OTEL_ENABLED='$env:OTEL_ENABLED'
`$env:OTEL_SERVICE_NAME='$($service.OtelName)'
`$env:OTEL_EXPORTER_OTLP_ENDPOINT='$env:OTEL_EXPORTER_OTLP_ENDPOINT'
Set-Location '$servicePath'
bundle install
bundle exec rackup --host 0.0.0.0 --port $($service.Port)
"@

  Start-Process powershell -ArgumentList "-NoExit", "-Command", $command
}

Write-Host "Started local microservices. Use -WithOtel to enable OpenTelemetry env variables."
