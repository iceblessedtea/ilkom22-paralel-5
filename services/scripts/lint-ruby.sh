#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

files=(
  "services/patient-service/app/api.rb"
  "services/patient-service/config.ru"
  "services/doctor-service/app/api.rb"
  "services/doctor-service/config.ru"
  "services/appointment-service/app/api.rb"
  "services/appointment-service/config.ru"
  "services/medical-record-service/app/api.rb"
  "services/medical-record-service/config.ru"
  "observability/ruby/otel.rb"
)

for file in "${files[@]}"; do
  echo "==> ruby -c ${file}"
  ruby -c "${ROOT_DIR}/${file}"
done
