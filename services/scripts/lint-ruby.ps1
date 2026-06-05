$ErrorActionPreference = "Stop"

$root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$files = @(
  "services/patient-service/app/api.rb",
  "services/patient-service/config.ru",
  "services/doctor-service/app/api.rb",
  "services/doctor-service/config.ru",
  "services/appointment-service/app/api.rb",
  "services/appointment-service/config.ru",
  "services/medical-record-service/app/api.rb",
  "services/medical-record-service/config.ru",
  "observability/ruby/otel.rb"
)

foreach ($file in $files) {
  Write-Host "==> ruby -c $file"
  ruby -c (Join-Path $root $file)
}
