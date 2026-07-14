#!/usr/bin/env python3
from __future__ import annotations

import csv
import re
import sys
from collections import OrderedDict
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parents[4]
MANIFEST_FILE = REPO_ROOT / "database/schema/master/MAS_06_seed_manifest.csv"
TOP100_FILE = REPO_ROOT / "database/schema/master/MAS_05_top100_all_tables.txt"
COLUMNS_FILE = REPO_ROOT / "database/metadata/export-20260713/02_columns.csv"
OUTPUT_FILE = REPO_ROOT / "database/schema/master/MAS_08_seed_from_top100.sql"
RELAXED_OUTPUT_FILE = REPO_ROOT / "database/schema/master/MAS_09_seed_all_top100_relaxed.sql"
UNSUPPORTED_TEXT_EXPORT_TYPES = {"image", "binary", "varbinary", "timestamp", "rowversion"}
STRING_TYPES = {"varchar", "char", "text", "nvarchar", "nchar", "ntext"}

TIERS_TO_INCLUDE = {"0", "1", "2", "6"}
EXPLICIT_INCLUDE = {
    "dbo.tCompany",
    "dbo.tSSO_Account",
    "dbo.tProject",
    "dbo.tSiteTR",
    "dbo.tCostCenter",
    "dbo.tBU1",
    "dbo.tBU2",
    "dbo.tBU3",
    "dbo.tBU4",
    "dbo.tEmployeeStatusGroup",
    "dbo.tEmployeeStatus",
    "dbo.tEmployeeTitle",
    "dbo.tEmployeeLevel",
    "dbo.tEmployeeType1",
    "dbo.tEmployeeType2",
    "dbo.tEmployeeType3",
    "dbo.tGender",
    "dbo.tNationality",
    "dbo.tPrefix",
    "dbo.tMartialStatus",
    "dbo.tShift",
    "dbo.tWorkCalendar",
    "dbo.tWorkCalendarDetail",
    "dbo.tPMPeriod",
    "dbo.tTaxRate",
    "dbo.tBankMaster",
    "dbo.tBankName",
    "dbo.tSSO_Hospital",
    "dbo.tSSO_ResignReason",
    "dbo.tUserGroup",
    "dbo.tUser",
    "dbo.tSYSUserRole",
    "dbo.tAssignUserRole",
    "dbo.tAssignMenuPermission",
    "dbo.tRequestSystem",
    "dbo.tRequestType",
    "dbo.tRule",
    "dbo.tFlow",
    "dbo.tFlowPath",
    "customize.tInfoExportGroup",
    "customize.tInfoExportGroupDetail",
    "customize.tMOD_LogSetting",
    "customize.tSCC_AprvSite",
    "customize.tSCC_SettingPayAllowance",
}


def load_manifest() -> list[dict[str, str]]:
    with MANIFEST_FILE.open(encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


def load_column_types() -> dict[str, OrderedDict[str, str]]:
    result: dict[str, OrderedDict[str, str]] = {}
    with COLUMNS_FILE.open(encoding="utf-8-sig", newline="") as handle:
        for row in csv.reader(handle):
            schema_name, table_name, _, column_name, data_type, *_ = row
            table_key = f"{schema_name}.{table_name}"
            result.setdefault(table_key, OrderedDict())[column_name] = data_type.lower()
    return result


def load_identity_columns() -> dict[str, set[str]]:
    result: dict[str, set[str]] = {}
    with COLUMNS_FILE.open(encoding="utf-8-sig", newline="") as handle:
        for row in csv.reader(handle):
            schema_name, table_name, _, column_name, _data_type, *_unused, identity_flag, _default = row
            if identity_flag == "1":
                table_key = f"{schema_name}.{table_name}"
                result.setdefault(table_key, set()).add(column_name)
    return result


def parse_sections() -> dict[str, dict[str, object]]:
    lines = TOP100_FILE.read_text(encoding="utf-8-sig").splitlines()
    sections: dict[str, dict[str, object]] = {}
    i = 0
    while i < len(lines):
        line = lines[i].rstrip("\n")
        if not line.startswith("====="):
            i += 1
            continue

        section_name = line.replace("=", "").strip()
        if i + 2 >= len(lines):
            break

        header = lines[i + 1]
        underline = lines[i + 2]
        spans = [(m.start(), m.end()) for m in re.finditer(r"-+", underline)]
        columns = [header[start:end].strip() for start, end in spans]

        rows: list[dict[str, str]] = []
        i += 3
        while i < len(lines):
            current = lines[i]
            if current.startswith("====="):
                break
            if current.strip() == "":
                i += 1
                continue

            padded = current + (" " * max(0, len(underline) - len(current)))
            record: dict[str, str] = {}
            for (start, end), column_name in zip(spans, columns):
                record[column_name] = padded[start:end].strip()
            rows.append(record)
            i += 1

        sections[section_name] = {"columns": columns, "rows": rows}
    return sections


def sql_literal(value: str, data_type: str) -> str:
    if value == "NULL":
        return "NULL"
    if value == "":
        return "N''" if data_type in {"nvarchar", "nchar", "ntext"} else ("''" if data_type in STRING_TYPES else "NULL")

    if data_type == "bit":
        return "1" if value not in {"0", "False", "false"} else "0"

    if data_type in {
        "int",
        "bigint",
        "smallint",
        "tinyint",
        "decimal",
        "numeric",
        "float",
        "real",
        "money",
        "smallmoney",
    }:
        return value

    escaped = value.replace("'", "''")

    if data_type in {"varchar", "char", "text"}:
        return f"'{escaped}'"

    if data_type in {"nvarchar", "nchar", "ntext"}:
        return f"N'{escaped}'"

    if data_type in {"uniqueidentifier", "datetime", "smalldatetime", "date", "time", "datetime2"}:
        return f"'{escaped}'"

    return f"N'{escaped}'"


def should_include(row: dict[str, str]) -> bool:
    if row["tier"] not in TIERS_TO_INCLUDE:
        return False
    if row["seed_mode"] == "SKIP":
        return False
    table_key = f"{row['schema_name']}.{row['table_name']}"
    return table_key in EXPLICIT_INCLUDE


def build_manifest_rows(all_relaxed: bool, section_map: dict[str, dict[str, object]]) -> list[dict[str, str]]:
    if not all_relaxed:
        return [row for row in load_manifest() if should_include(row)]

    rows: list[dict[str, str]] = []
    for table_key in section_map:
        if "." not in table_key:
            continue
        schema_name, table_name = table_key.split(".", 1)
        rows.append(
            {
                "tier": "all",
                "seed_mode": "RELAXED",
                "sample_limit": "",
                "schema_name": schema_name,
                "table_name": table_name,
                "row_count": "",
                "reason": "parsed from MAS_05_top100_all_tables.txt",
            }
        )
    return rows


def build_sql(all_relaxed: bool = False) -> str:
    section_map = parse_sections()
    manifest_rows = build_manifest_rows(all_relaxed, section_map)
    column_types = load_column_types()
    identity_columns = load_identity_columns()

    chunks: list[str] = []
    chunks.append("-- Generated from MAS_05_top100_all_tables.txt and MAS_06_seed_manifest.csv")
    if all_relaxed:
        chunks.append("-- Purpose: seed the local analysis database with all parseable TOP 100/FULL text-export rows")
        chunks.append("-- Analysis mode: FK constraints are disabled during load and re-enabled as untrusted constraints.")
    else:
        chunks.append("-- Purpose: seed the local analysis database with parseable master/reference/sample rows")
    chunks.append("-- Safe rerun is not guaranteed; this file assumes an empty analysis DB.")
    chunks.append("SET NOCOUNT ON;")
    if all_relaxed:
        chunks.append("EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';")
    chunks.append("")

    for row in manifest_rows:
        table_key = f"{row['schema_name']}.{row['table_name']}"
        section = section_map.get(table_key)
        if not section:
            chunks.append(f"-- SKIP {table_key}: section not found in MAS_05_top100_all_tables.txt")
            chunks.append("")
            continue

        source_columns = [c for c in section["columns"] if c != "__SourceTable"]
        type_map = column_types.get(table_key)
        if not type_map:
            chunks.append(f"-- SKIP {table_key}: column metadata not found")
            chunks.append("")
            continue

        known_columns = [
            c for c in source_columns if c in type_map and type_map[c] not in UNSUPPORTED_TEXT_EXPORT_TYPES
        ]
        skipped_columns = [
            c for c in source_columns if c not in type_map or type_map.get(c) in UNSUPPORTED_TEXT_EXPORT_TYPES
        ]

        chunks.append(f"PRINT N'===== SEED: {table_key} =====';")
        if skipped_columns:
            skipped = ", ".join(skipped_columns)
            chunks.append(f"-- Warning: skipped unmapped columns: {skipped}")

        table_identity_columns = identity_columns.get(table_key, set())
        needs_identity_insert = any(column_name in table_identity_columns for column_name in known_columns)
        if needs_identity_insert:
            chunks.append(f"SET IDENTITY_INSERT [{row['schema_name']}].[{row['table_name']}] ON;")

        rows = section["rows"]
        if "__SourceTable" in section["columns"]:
            rows = [parsed for parsed in rows if parsed.get("__SourceTable") == table_key]
        if not rows:
            chunks.append(f"-- No rows parsed for {table_key}")
            chunks.append("")
            continue

        for parsed in rows:
            values = []
            for column_name in known_columns:
                raw_value = parsed.get(column_name, "")
                data_type = type_map[column_name]
                values.append(sql_literal(raw_value, data_type))

            column_list = ", ".join(f"[{name}]" for name in known_columns)
            value_list = ", ".join(values)
            chunks.append(
                f"INSERT INTO [{row['schema_name']}].[{row['table_name']}] ({column_list}) VALUES ({value_list});"
            )

        if needs_identity_insert:
            chunks.append(f"SET IDENTITY_INSERT [{row['schema_name']}].[{row['table_name']}] OFF;")
        chunks.append("GO")
        chunks.append("")

    if all_relaxed:
        chunks.append("EXEC sp_MSforeachtable 'ALTER TABLE ? WITH NOCHECK CHECK CONSTRAINT ALL';")
        chunks.append("GO")
        chunks.append("")

    return "\n".join(chunks) + "\n"


def main() -> None:
    all_relaxed = "--all-relaxed" in sys.argv
    output_file = RELAXED_OUTPUT_FILE if all_relaxed else OUTPUT_FILE
    output_file.write_text(build_sql(all_relaxed=all_relaxed), encoding="utf-8")
    print(f"Wrote {output_file}")


if __name__ == "__main__":
    main()
