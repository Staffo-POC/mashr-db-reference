#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MSSQL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
ENV_FILE="${REPO_ROOT}/.env"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <seed-sql-file-under-database/schema/master-or-database/scripts/mssql/generated>" >&2
  exit 1
fi

INPUT_PATH="$1"

case "${INPUT_PATH}" in
  database/schema/master/*)
    CONTAINER_PATH="/workspace/${INPUT_PATH}"
    ;;
  database/scripts/mssql/generated/*)
    CONTAINER_PATH="/workspace/db/generated/${INPUT_PATH#database/scripts/mssql/generated/}"
    ;;
  *)
    echo "Only files under database/schema/master or database/scripts/mssql/generated are supported." >&2
    exit 1
    ;;
esac

cd "${REPO_ROOT}"

if [[ ! -f "${ENV_FILE}" ]]; then
  cp "${REPO_ROOT}/.env.example" "${ENV_FILE}"
fi

set -a
source "${ENV_FILE}"
set +a

if [[ ! -f "${REPO_ROOT}/${INPUT_PATH}" ]]; then
  echo "Input file not found: ${REPO_ROOT}/${INPUT_PATH}" >&2
  exit 1
fi

CONTAINER_NAME="mashr-db"
DATABASE_NAME="${MSSQL_DATABASE:-MAS}"
DB_USER="${MSSQL_USER:-sa}"

if docker exec "${CONTAINER_NAME}" /opt/mssql-tools18/bin/sqlcmd -S localhost -U "${DB_USER}" -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1" >/dev/null 2>&1; then
  SQLCMD="/opt/mssql-tools18/bin/sqlcmd -C"
elif docker exec "${CONTAINER_NAME}" /opt/mssql-tools/bin/sqlcmd -S localhost -U "${DB_USER}" -P "${MSSQL_SA_PASSWORD}" -Q "SELECT 1" >/dev/null 2>&1; then
  SQLCMD="/opt/mssql-tools/bin/sqlcmd"
else
  echo "SQL Server is not ready, or sqlcmd was not found in the container." >&2
  exit 1
fi

docker exec "${CONTAINER_NAME}" ${SQLCMD} \
  -S localhost \
  -U "${DB_USER}" \
  -P "${MSSQL_SA_PASSWORD}" \
  -d "${DATABASE_NAME}" \
  -b \
  -r 1 \
  -i "${CONTAINER_PATH}"
