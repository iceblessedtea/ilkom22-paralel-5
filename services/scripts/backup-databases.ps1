param(
  [string]$OutputDirectory = (Join-Path $PSScriptRoot "..\backups")
)

$ErrorActionPreference = "Stop"

$servicesDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$backupDir = Join-Path $OutputDirectory $timestamp
$databases = @(
  "patient_service",
  "doctor_service",
  "appointment_service",
  "medical_record_service"
)

New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

Push-Location $servicesDir
try {
  docker compose up -d postgres

  foreach ($database in $databases) {
    $containerFile = "/tmp/$database.sql"
    $destination = Join-Path $backupDir "$database.sql"

    Write-Host "==> Backing up $database"
    docker compose exec -T postgres pg_dump `
      --username healthcare `
      --dbname $database `
      --clean `
      --if-exists `
      --no-owner `
      --no-privileges `
      --file $containerFile

    if ($LASTEXITCODE -ne 0) {
      throw "pg_dump failed for $database"
    }

    docker compose cp "postgres:$containerFile" $destination
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to copy backup for $database"
    }

    docker compose exec -T postgres rm -f $containerFile
  }
}
finally {
  Pop-Location
}

$manifest = @{
  created_at = (Get-Date).ToString("o")
  databases = $databases
  format = "plain-sql"
} | ConvertTo-Json

Set-Content -Path (Join-Path $backupDir "manifest.json") -Value $manifest -Encoding utf8
Write-Host "Backup completed: $backupDir"
