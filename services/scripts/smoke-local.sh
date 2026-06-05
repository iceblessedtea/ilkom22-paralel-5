#!/usr/bin/env bash
set -euo pipefail

check_json() {
  local label="$1"
  local url="$2"
  echo "==> ${label}: ${url}"
  curl --fail --silent --show-error "${url}" >/dev/null
}

check_json "patient health" "http://localhost:7860/health"
check_json "doctor health" "http://localhost:7861/health"
check_json "appointment health" "http://localhost:7862/health"
check_json "medical record health" "http://localhost:7863/health"
check_json "patients list" "http://localhost:7860/patients"
check_json "doctors list" "http://localhost:7861/doctors"
check_json "appointments list" "http://localhost:7862/appointments"
check_json "medical records list" "http://localhost:7863/medical-records"

echo "Local smoke test passed."
