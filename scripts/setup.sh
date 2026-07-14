#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if [[ ! -f ".env" ]]; then
  echo "Creating .env from .env.example..."
  cp .env.example .env
fi

set -a
source .env
set +a

echo "Starting MAS HR SQL Server..."
docker compose --env-file .env up -d

echo "Waiting for SQL Server..."
"${ROOT_DIR}/database/scripts/mssql/wait-for-mssql.sh"

echo "Importing MAS HR database..."
"${ROOT_DIR}/database/scripts/mssql/import.sh"

echo "Verifying database..."
"${ROOT_DIR}/database/scripts/mssql/verify.sh"

echo
echo "MAS HR database is ready."
echo "Server   : localhost,${MSSQL_PORT:-14333}"
echo "Database : ${MSSQL_DATABASE:-MAS}"
echo "Username : ${MSSQL_USER:-sa}"
echo "Password : see .env"
