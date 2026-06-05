$ErrorActionPreference = "Stop"

$servicesDir = Resolve-Path (Join-Path $PSScriptRoot "..")

function Cleanup {
  Push-Location $servicesDir
  try {
    docker compose down --remove-orphans
  }
  finally {
    Pop-Location
  }
}

try {
  Push-Location $servicesDir
  docker compose up -d --build

  $checks = @(
    "http://localhost/api/health",
    "http://localhost/api/patients",
    "http://localhost/api/doctors",
    "http://localhost/api/appointments",
    "http://localhost/api/medical-records"
  )

  foreach ($url in $checks) {
    Write-Host "==> $url"
    $ready = $false
    for ($attempt = 1; $attempt -le 30; $attempt++) {
      try {
        Invoke-RestMethod -Uri $url | Out-Null
        $ready = $true
        break
      }
      catch {
        Start-Sleep -Seconds 2
      }
    }

    if (-not $ready) {
      docker compose ps
      docker compose logs --tail=80
      throw "Endpoint did not become ready: $url"
    }
  }

  curl.exe --fail --silent --show-error `
    -X OPTIONS `
    "http://localhost/api/patients" `
    -H "Origin: http://localhost:5173" `
    -H "Access-Control-Request-Method: GET" | Out-Null

  if ($LASTEXITCODE -ne 0) {
    throw "CORS preflight failed."
  }

  Write-Host "Docker smoke test passed."
}
finally {
  Pop-Location
  Cleanup
}
