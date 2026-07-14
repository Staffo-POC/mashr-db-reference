#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
MANIFEST_FILE="${REPO_ROOT}/database/schema/master/MAS_06_seed_manifest.csv"
OUTPUT_FILE="${REPO_ROOT}/database/schema/master/MAS_07_seed_export_queries.sql"

if [[ ! -f "${MANIFEST_FILE}" ]]; then
  echo "Manifest not found: ${MANIFEST_FILE}" >&2
  exit 1
fi

{
  echo "-- Generated from database/schema/master/MAS_06_seed_manifest.csv"
  echo "-- Purpose: run on the source MAS database to export a curated seed result set."
  echo "-- Notes:"
  echo "--   1. FULL rows are exported without TOP."
  echo "--   2. SAMPLE rows use the manifest sample_limit."
  echo "--   3. SKIP rows are emitted as comments only."
  echo

  awk -F',' '
    NR == 1 { next }
    {
      tier = $1
      mode = $2
      sample_limit = $3
      schema_name = $4
      table_name = $5
      row_count = $6
      reason = $7
      source_table = schema_name "." table_name

      if (tier != current_tier) {
        current_tier = tier
        printf "\n-- Tier %s\n\n", tier
      }

      if (mode == "SKIP") {
        printf "-- SKIP %s (%s rows) - %s\n\n", source_table, row_count, reason
        next
      }

      if (mode == "FULL") {
        printf "PRINT N'\''===== FULL: %s (%s rows) ====='\'';\n", source_table, row_count
        printf "SELECT N'\''%s'\'' AS [__SourceTable], * FROM [%s].[%s];\n", source_table, schema_name, table_name
        printf "GO\n\n"
        next
      }

      if (mode == "SAMPLE") {
        if (sample_limit == "") {
          sample_limit = 100
        }
        printf "PRINT N'\''===== SAMPLE: %s (TOP %s of %s) ====='\'';\n", source_table, sample_limit, row_count
        printf "SELECT TOP (%s) N'\''%s'\'' AS [__SourceTable], * FROM [%s].[%s];\n", sample_limit, source_table, schema_name, table_name
        printf "GO\n\n"
      }
    }
  ' "${MANIFEST_FILE}"
} > "${OUTPUT_FILE}"

echo "Wrote ${OUTPUT_FILE}"
