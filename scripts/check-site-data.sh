#!/usr/bin/env bash
# Print a data-quality report for the company/site area of the local database.
#
#   ./scripts/check-site-data.sh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

[[ -f .env ]] || cp .env.example .env
set -a
source .env
set +a

CONTAINER_NAME="mashr-db"
DATABASE_NAME="${MSSQL_DATABASE:-MAS}"
DB_USER="${MSSQL_USER:-sa}"
REPORT="/workspace/database/scripts/mssql/site-data-quality.sql"

if ! docker ps --format '{{.Names}}' | grep -qx "${CONTAINER_NAME}"; then
  echo "Container ${CONTAINER_NAME} is not running. Start it with ./scripts/start.sh" >&2
  exit 1
fi

if docker exec "${CONTAINER_NAME}" test -x /opt/mssql-tools18/bin/sqlcmd 2>/dev/null; then
  SQLCMD=(/opt/mssql-tools18/bin/sqlcmd -C)
else
  SQLCMD=(/opt/mssql-tools/bin/sqlcmd)
fi

docker exec "${CONTAINER_NAME}" "${SQLCMD[@]}" \
  -S localhost \
  -U "${DB_USER}" \
  -P "${MSSQL_SA_PASSWORD}" \
  -d "${DATABASE_NAME}" \
  -W -s ' | ' -w 200 \
  -i "${REPORT}"
