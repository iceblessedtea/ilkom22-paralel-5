param(
  [Parameter(Mandatory = $true)]
  [string]$BackupDirectory,
  [ValidateSet("all", "patient_service", "doctor_service", "appointment_service", "medical_record_service")]
  [string]$Database = "all"
)

$ErrorActionPreference = "Stop"

$servicesDir = Resolve-Path (Join-Path $PSScriptRoot "..")
$resolvedBackup = Resolve-Path $BackupDirectory
$databases = if ($Database -eq "all") {
  @("patient_service", "doctor_service", "appointment_service", "medical_record_service")
} else {
  @($Database)
}

Push-Location $servicesDir
try {
  docker compose up -d postgres

  foreach ($databaseName in $databases) {
    $source = Join-Path $resolvedBackup "$databaseName.sql"
    if (-not (Test-Path $source)) {
      throw "Backup file not found: $source"
    }

    $containerFile = "/tmp/$databaseName-restore.sql"
    Write-Host "==> Restoring $databaseName"

    docker compose cp $source "postgres:$containerFile"
    if ($LASTEXITCODE -ne 0) {
      throw "Failed to copy restore file for $databaseName"
    }

    docker compose exec -T postgres psql `
      --username healthcare `
      --dbname $databaseName `
      --set ON_ERROR_STOP=1 `
      --file $containerFile

    if ($LASTEXITCODE -ne 0) {
      throw "Restore failed for $databaseName"
    }

    docker compose exec -T postgres rm -f $containerFile
  }
}
finally {
  Pop-Location
}

Write-Host "Restore completed for: $($databases -join ', ')"
