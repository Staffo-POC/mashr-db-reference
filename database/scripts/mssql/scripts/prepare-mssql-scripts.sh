#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MSSQL_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/../../../.." && pwd)"
MASTER_DIR="${ROOT_DIR}/database/schema/master"
GENERATED_DIR="${MSSQL_DIR}/generated"
LOG_DIR="${MSSQL_DIR}/logs"

if [[ -f "${ROOT_DIR}/.env" ]]; then
  set -a
  source "${ROOT_DIR}/.env"
  set +a
fi

DATABASE_NAME="${MSSQL_DATABASE:-MAS}"

mkdir -p "${GENERATED_DIR}" "${LOG_DIR}"

convert_sql() {
  local source_file="$1"
  local target_file="$2"

  if file "${source_file}" | grep -qi 'utf-16'; then
    iconv -f UTF-16 -t UTF-8 "${source_file}" > "${target_file}"
  else
    cp "${source_file}" "${target_file}"
  fi
}

cat > "${GENERATED_DIR}/00_bootstrap.sql" <<SQL
USE [master]
GO

IF DB_ID(N'${DATABASE_NAME}') IS NULL
BEGIN
    CREATE DATABASE [${DATABASE_NAME}] COLLATE Thai_CI_AS;
END
GO

ALTER DATABASE [${DATABASE_NAME}] SET RECOVERY SIMPLE;
GO

USE [${DATABASE_NAME}]
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'billing') EXEC('CREATE SCHEMA [billing]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'customize') EXEC('CREATE SCHEMA [customize]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'dbo2') EXEC('CREATE SCHEMA [dbo2]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'license') EXEC('CREATE SCHEMA [license]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'mas_form') EXEC('CREATE SCHEMA [mas_form]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'mas_report') EXEC('CREATE SCHEMA [mas_report]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'maspayroll') EXEC('CREATE SCHEMA [maspayroll]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'masuser') EXEC('CREATE SCHEMA [masuser]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'outpay_form') EXEC('CREATE SCHEMA [outpay_form]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'outpay_report') EXEC('CREATE SCHEMA [outpay_report]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'payroll') EXEC('CREATE SCHEMA [payroll]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'reporter') EXEC('CREATE SCHEMA [reporter]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'rosetta') EXEC('CREATE SCHEMA [rosetta]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'service') EXEC('CREATE SCHEMA [service]');
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'user') EXEC('CREATE SCHEMA [user]');
GO

IF OBJECT_ID(N'dbo.fDefaultRowGuid', N'FN') IS NULL
    EXEC('
    CREATE FUNCTION [dbo].[fDefaultRowGuid]()
    RETURNS uniqueidentifier
    AS
    BEGIN
        RETURN ''FFFFFFFF-FFFF-FFFF-FFFF-FFFFFFFFFFFF'';
    END
    ');
GO
SQL

cat > "${GENERATED_DIR}/02_known_stubs.sql" <<SQL
USE [${DATABASE_NAME}]
GO

IF OBJECT_ID(N'dbo.fConvertDateBioStar', N'FN') IS NULL
    EXEC('
    CREATE FUNCTION [dbo].[fConvertDateBioStar] (@pnDateTime varchar(255))
    RETURNS varchar(255)
    AS
    BEGIN
        DECLARE @converted varchar(255);

        SELECT @converted = LEFT([dbo].[fConvertDateTimeBioStar](@pnDateTime), 10);
        RETURN @converted;
    END
    ');
GO
SQL

cat > "${GENERATED_DIR}/99_smoke_test.sql" <<SQL
USE [${DATABASE_NAME}]
GO

SELECT
    DB_NAME() AS database_name,
    (SELECT COUNT(*) FROM sys.tables) AS table_count,
    (SELECT COUNT(*) FROM sys.views) AS view_count,
    (SELECT COUNT(*) FROM sys.procedures) AS procedure_count,
    (SELECT COUNT(*) FROM sys.objects WHERE type IN ('FN', 'IF', 'TF')) AS function_count;
GO
SQL

convert_sql "${MASTER_DIR}/MAS_01_tables.sql" "${GENERATED_DIR}/01_tables.sql"
convert_sql "${MASTER_DIR}/MAS_03_functions.sql" "${GENERATED_DIR}/03_functions.sql"
convert_sql "${MASTER_DIR}/MAS_02_programmability.sql" "${GENERATED_DIR}/04_programmability.sql"

perl -0pi -e 's{/\*\*\*\*\*\* Object:\s+UserDefinedFunction \[dbo\]\.\[fDefaultRowGuid\].*?GO\r?\n(?=/\*\*\*\*\*\* Object:\s+UserDefinedFunction \[dbo\]\.\[fDefineDefaultShift\])}{}s' "${GENERATED_DIR}/03_functions.sql"

printf 'Prepared SQL files in %s\n' "${GENERATED_DIR}"
