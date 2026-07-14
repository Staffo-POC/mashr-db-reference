#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

if [[ ! -f ".env" ]]; then
  cp .env.example .env
fi

docker compose --env-file .env up -d
"${ROOT_DIR}/database/scripts/mssql/wait-for-mssql.sh"
