#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
cd "${ROOT_DIR}"

if [[ ! -f ".env" ]]; then
  cp .env.example .env
fi

set -a
source .env
set +a

CONTAINER_NAME="mashr-db"
MAX_RETRIES=60
RETRY_INTERVAL=3

echo "Waiting for container ${CONTAINER_NAME}..."

for ((i = 1; i <= MAX_RETRIES; i++)); do
  if docker exec "${CONTAINER_NAME}" /opt/mssql-tools18/bin/sqlcmd \
    -S localhost \
    -U "${MSSQL_USER:-sa}" \
    -P "${MSSQL_SA_PASSWORD}" \
    -C \
    -Q "SELECT 1" >/dev/null 2>&1; then
    echo "SQL Server is ready."
    exit 0
  fi

  if docker exec "${CONTAINER_NAME}" /opt/mssql-tools/bin/sqlcmd \
    -S localhost \
    -U "${MSSQL_USER:-sa}" \
    -P "${MSSQL_SA_PASSWORD}" \
    -Q "SELECT 1" >/dev/null 2>&1; then
    echo "SQL Server is ready."
    exit 0
  fi

  echo "Attempt ${i}/${MAX_RETRIES}: SQL Server is not ready yet..."
  sleep "${RETRY_INTERVAL}"
done

echo "SQL Server did not become ready." >&2
docker logs "${CONTAINER_NAME}" >&2
exit 1
