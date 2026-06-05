$ErrorActionPreference = "Stop"

$checks = @(
  @{ Label = "patient health"; Url = "http://localhost:7860/health" },
  @{ Label = "doctor health"; Url = "http://localhost:7861/health" },
  @{ Label = "appointment health"; Url = "http://localhost:7862/health" },
  @{ Label = "medical record health"; Url = "http://localhost:7863/health" },
  @{ Label = "patients list"; Url = "http://localhost:7860/patients" },
  @{ Label = "doctors list"; Url = "http://localhost:7861/doctors" },
  @{ Label = "appointments list"; Url = "http://localhost:7862/appointments" },
  @{ Label = "medical records list"; Url = "http://localhost:7863/medical-records" }
)

foreach ($check in $checks) {
  Write-Host "==> $($check.Label): $($check.Url)"
  Invoke-RestMethod -Uri $check.Url | Out-Null
}

Write-Host "Local smoke test passed."
