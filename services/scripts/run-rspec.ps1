$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$services = @(
  "patient-service",
  "doctor-service",
  "appointment-service",
  "medical-record-service"
)

foreach ($service in $services) {
  Write-Host "==> RSpec: $service"
  Push-Location (Join-Path $root "services\$service")
  try {
    bundle install
    bundle exec rspec
  }
  finally {
    Pop-Location
  }
}
