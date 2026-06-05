#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WITH_OTEL="false"

if [[ "${1:-}" == "--with-otel" || "${1:-}" == "--otel" ]]; then
  WITH_OTEL="true"
fi

export PATIENT_URL="${PATIENT_URL:-http://localhost:7860}"
export DOCTOR_URL="${DOCTOR_URL:-http://localhost:7861}"
export APPOINTMENT_URL="${APPOINTMENT_URL:-http://localhost:7862}"
export MEDICAL_RECORD_URL="${MEDICAL_RECORD_URL:-http://localhost:7863}"
export OTEL_ENABLED="$WITH_OTEL"
export OTEL_EXPORTER_OTLP_ENDPOINT="${OTEL_EXPORTER_OTLP_ENDPOINT:-http://localhost:4318}"

start_service() {
  local name="$1"
  local port="$2"
  local database="$3"

  (
    cd "$ROOT_DIR/$name"
    export PORT="$port"
    export DATABASE_URL="${DATABASE_URL:-postgres://healthcare:healthcare@localhost:5432/${database}}"
    export OTEL_SERVICE_NAME="$name"
    bundle install
    bundle exec ruby db/migrate.rb
    bundle exec rackup --host 0.0.0.0 --port "$port"
  ) &
}

start_service patient-service 7860 patient_service
start_service doctor-service 7861 doctor_service
start_service appointment-service 7862 appointment_service
start_service medical-record-service 7863 medical_record_service

echo "Started local microservices. Use --with-otel to enable OpenTelemetry env variables."
wait
