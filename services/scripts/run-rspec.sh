#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

services=(
  "patient-service"
  "doctor-service"
  "appointment-service"
  "medical-record-service"
)

for service in "${services[@]}"; do
  echo "==> RSpec: ${service}"
  (
    cd "${ROOT_DIR}/services/${service}"
    bundle install
    bundle exec rspec
  )
done
