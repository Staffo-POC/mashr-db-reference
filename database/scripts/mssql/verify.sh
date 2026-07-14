#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
MSSQL_DIR="${ROOT_DIR}/database/scripts/mssql"
cd "${ROOT_DIR}"

if [[ ! -f ".env" ]]; then
  cp .env.example .env
fi

set -a
source .env
set +a

CONTAINER_NAME="mashr-db"
DATABASE_NAME="${MSSQL_DATABASE:-MAS}"

if [[ ! -f "${MSSQL_DIR}/generated/99_smoke_test.sql" ]]; then
  "${MSSQL_DIR}/scripts/prepare-mssql-scripts.sh"
fi

if docker exec "${CONTAINER_NAME}" /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U "${MSSQL_USER:-sa}" \
  -P "${MSSQL_SA_PASSWORD}" \
  -C \
  -d "${DATABASE_NAME}" \
  -i /workspace/db/generated/99_smoke_test.sql; then
  exit 0
fi

docker exec "${CONTAINER_NAME}" /opt/mssql-tools/bin/sqlcmd \
  -S localhost \
  -U "${MSSQL_USER:-sa}" \
  -P "${MSSQL_SA_PASSWORD}" \
  -d "${DATABASE_NAME}" \
  -i /workspace/db/generated/99_smoke_test.sql
