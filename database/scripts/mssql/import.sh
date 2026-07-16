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
DB_USER="${MSSQL_USER:-sa}"

"${MSSQL_DIR}/scripts/prepare-mssql-scripts.sh"

SQLCMD=""
if docker exec "${CONTAINER_NAME}" /opt/mssql-tools18/bin/sqlcmd -S localhost -U "${DB_USER}" -P "${MSSQL_SA_PASSWORD}" -C -Q "SELECT 1" >/dev/null 2>&1; then
  SQLCMD="/opt/mssql-tools18/bin/sqlcmd -C"
elif docker exec "${CONTAINER_NAME}" /opt/mssql-tools/bin/sqlcmd -S localhost -U "${DB_USER}" -P "${MSSQL_SA_PASSWORD}" -Q "SELECT 1" >/dev/null 2>&1; then
  SQLCMD="/opt/mssql-tools/bin/sqlcmd"
else
  echo "SQL Server is not ready, or sqlcmd was not found in the container." >&2
  exit 1
fi

run_sql() {
  local label="$1"
  local sql_file="$2"
  local mode="${3:-strict}"
  local log_file="${MSSQL_DIR}/logs/${label}.log"

  local db_flag=""
  if [[ "${label}" != "00_bootstrap" ]]; then
    db_flag="-d ${DATABASE_NAME}"
  fi

  echo "Importing ${label}..."
  set +e
  if [[ "${mode}" == "strict" ]]; then
    docker exec "${CONTAINER_NAME}" ${SQLCMD} \
      -S localhost \
      -U "${DB_USER}" \
      -P "${MSSQL_SA_PASSWORD}" \
      ${db_flag} \
      -b \
      -r 1 \
      -i "/workspace/db/generated/${sql_file}" \
      > "${log_file}" 2>&1
  else
    docker exec "${CONTAINER_NAME}" ${SQLCMD} \
      -S localhost \
      -U "${DB_USER}" \
      -P "${MSSQL_SA_PASSWORD}" \
      ${db_flag} \
      -r 1 \
      -i "/workspace/db/generated/${sql_file}" \
      > "${log_file}" 2>&1
  fi
  local status=$?
  set -e

  if [[ ${status} -ne 0 && "${mode}" == "strict" ]]; then
    echo "Import step failed: ${label}. See ${log_file}" >&2
    return ${status}
  fi

  if [[ "${mode}" != "strict" ]]; then
    local error_count
    error_count="$(grep -c '^Msg ' "${log_file}" || true)"
    echo "  ${label} completed best-effort with ${error_count} logged SQL errors."
  fi
}

echo "Resetting analysis database ${DATABASE_NAME}..."
docker exec "${CONTAINER_NAME}" ${SQLCMD} \
  -S localhost \
  -U "${DB_USER}" \
  -P "${MSSQL_SA_PASSWORD}" \
  -b \
  -r 1 \
  -Q "IF DB_ID(N'${DATABASE_NAME}') IS NOT NULL BEGIN ALTER DATABASE [${DATABASE_NAME}] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [${DATABASE_NAME}]; END" \
  > "${MSSQL_DIR}/logs/00_reset.log" 2>&1

run_sql "00_bootstrap" "00_bootstrap.sql"
run_sql "01_tables" "01_tables.sql"
run_sql "03_functions" "03_functions.sql" "best-effort"
run_sql "02_known_stubs" "02_known_stubs.sql"
run_sql "04_programmability" "04_programmability.sql" "best-effort"

if [[ -f "${MSSQL_DIR}/generated/09_base_relaxed_seed.sql" ]]; then
  run_sql "09_base_relaxed_seed" "09_base_relaxed_seed.sql" "best-effort"
fi

if [[ -n "${MASHR_SEED_SNAPSHOT:-}" ]]; then
  SEED_DIR="${ROOT_DIR}/database/seed/${MASHR_SEED_SNAPSHOT}"
  if [[ ! -d "${SEED_DIR}" ]]; then
    echo "Seed snapshot not found: ${SEED_DIR}" >&2
    exit 1
  fi

  shopt -s nullglob
  seed_files=("${SEED_DIR}"/*.sql)
  shopt -u nullglob

  if [[ ${#seed_files[@]} -eq 0 ]]; then
    echo "No .sql files found in seed snapshot: ${SEED_DIR}"
  else
    for seed_file in "${seed_files[@]}"; do
      seed_name="$(basename "${seed_file}")"
      seed_label="seed_${MASHR_SEED_SNAPSHOT}_${seed_name%.sql}"
      echo "Importing seed ${MASHR_SEED_SNAPSHOT}/${seed_name}..."
      docker exec "${CONTAINER_NAME}" ${SQLCMD} \
        -S localhost \
        -U "${DB_USER}" \
        -P "${MSSQL_SA_PASSWORD}" \
        -d "${DATABASE_NAME}" \
        -b \
        -r 1 \
        -i "/workspace/database/seed/${MASHR_SEED_SNAPSHOT}/${seed_name}" \
        > "${MSSQL_DIR}/logs/${seed_label}.log" 2>&1
    done
  fi
else
  echo "No seed snapshot selected. Set MASHR_SEED_SNAPSHOT in .env to import approved seed data."
fi

run_sql "99_smoke_test" "99_smoke_test.sql"

echo "Done. Connection:"
echo "  Server: localhost,${MSSQL_PORT:-14333}"
echo "  User:   ${DB_USER}"
echo "  Pass:   ${MSSQL_SA_PASSWORD}"
echo "  DB:     ${DATABASE_NAME}"
