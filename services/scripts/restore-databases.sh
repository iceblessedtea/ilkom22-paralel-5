#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <backup-directory> [all|database-name]" >&2
  exit 1
fi

SERVICES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$(cd "$1" && pwd)"
DATABASE="${2:-all}"
POSTGRES_USER="${POSTGRES_USER:-healthcare}"
ALL_DATABASES=(
  patient_service
  doctor_service
  appointment_service
  medical_record_service
)

if [[ "${DATABASE}" == "all" ]]; then
  DATABASES=("${ALL_DATABASES[@]}")
elif [[ " ${ALL_DATABASES[*]} " == *" ${DATABASE} "* ]]; then
  DATABASES=("${DATABASE}")
else
  echo "Unknown database: ${DATABASE}" >&2
  exit 1
fi

cd "${SERVICES_DIR}"
docker compose up -d postgres

for database in "${DATABASES[@]}"; do
  source_file="${BACKUP_DIR}/${database}.sql"
  container_file="/tmp/${database}-restore.sql"

  if [[ ! -f "${source_file}" ]]; then
    echo "Backup file not found: ${source_file}" >&2
    exit 1
  fi

  echo "==> Restoring ${database}"
  docker compose cp "${source_file}" "postgres:${container_file}"
  docker compose exec -T postgres psql \
    --username "${POSTGRES_USER}" \
    --dbname "${database}" \
    --set ON_ERROR_STOP=1 \
    --file "${container_file}"
  docker compose exec -T postgres rm -f "${container_file}"
done

echo "Restore completed for: ${DATABASES[*]}"
