#!/usr/bin/env bash
set -euo pipefail

SERVICES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_ROOT="${1:-${SERVICES_DIR}/backups}"
TIMESTAMP="$(date -u +%Y%m%d-%H%M%S)"
BACKUP_DIR="${OUTPUT_ROOT}/${TIMESTAMP}"
DATABASES=(
  patient_service
  doctor_service
  appointment_service
  medical_record_service
)

mkdir -p "${BACKUP_DIR}"
cd "${SERVICES_DIR}"
docker compose up -d postgres

for database in "${DATABASES[@]}"; do
  container_file="/tmp/${database}.sql"
  echo "==> Backing up ${database}"

  docker compose exec -T postgres pg_dump \
    --username healthcare \
    --dbname "${database}" \
    --clean \
    --if-exists \
    --no-owner \
    --no-privileges \
    --file "${container_file}"

  docker compose cp "postgres:${container_file}" "${BACKUP_DIR}/${database}.sql"
  docker compose exec -T postgres rm -f "${container_file}"
done

cat >"${BACKUP_DIR}/manifest.json" <<EOF
{
  "created_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "format": "plain-sql",
  "databases": ["patient_service", "doctor_service", "appointment_service", "medical_record_service"]
}
EOF

echo "Backup completed: ${BACKUP_DIR}"
