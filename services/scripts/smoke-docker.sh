#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
SERVICES_DIR="${ROOT_DIR}/services"

cleanup() {
  (cd "${SERVICES_DIR}" && docker compose down --remove-orphans)
}
trap cleanup EXIT

cd "${SERVICES_DIR}"
docker compose up -d --build

checks=(
  "http://localhost/api/health"
  "http://localhost/api/patients"
  "http://localhost/api/doctors"
  "http://localhost/api/appointments"
  "http://localhost/api/medical-records"
)

for url in "${checks[@]}"; do
  echo "==> ${url}"
  for attempt in {1..30}; do
    if curl --fail --silent --show-error "${url}" >/dev/null; then
      break
    fi

    if [[ "${attempt}" == "30" ]]; then
      docker compose ps
      docker compose logs --tail=80
      exit 1
    fi

    sleep 2
  done
done

curl --fail --silent --show-error -X OPTIONS \
  "http://localhost/api/patients" \
  -H "Origin: http://localhost:5173" \
  -H "Access-Control-Request-Method: GET" >/dev/null

echo "Docker smoke test passed."
