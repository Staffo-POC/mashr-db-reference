# MAS Seed Runbook

This is the operational follow-up to the seed plan.

Files involved:

- [06-seed-data-plan.md](./06-seed-data-plan.md)
- [MAS_06_seed_manifest.csv](database/schema/master/MAS_06_seed_manifest.csv)
- [MAS_07_seed_export_queries.sql](database/schema/master/MAS_07_seed_export_queries.sql)
- [MAS_08_seed_from_top100.sql](database/schema/master/MAS_08_seed_from_top100.sql)
- [MAS_09_seed_all_top100_relaxed.sql](database/schema/master/MAS_09_seed_all_top100_relaxed.sql)

## What We Can Do In This Repo Today

1. Generate a curated SQL query file from the manifest.
2. Run that query file on the source MAS SQL Server.
3. Save the result as SQL inserts, CSV files, or another importable format.
4. Import the resulting seed SQL into the local Docker MSSQL analysis database.

There is now also a repo-local fallback:

- `MAS_08_seed_from_top100.sql` is generated from `MAS_05_top100_all_tables.txt`
- it is a first-wave seed containing parseable master/reference rows only
- it intentionally excludes tables that were not self-contained under current FK constraints

For broader analysis there is also a relaxed sample seed:

- `MAS_09_seed_all_top100_relaxed.sql` is generated from all parseable sections in `MAS_05_top100_all_tables.txt`
- the source text contains 290 table sections
- local import on 2026-07-13 seeded 288 tables / 14,232 rows
- this is not a production-complete seed; large tables are limited to the exported sample, normally `TOP 100`
- FK constraints are disabled during load and re-enabled as untrusted constraints, so this mode is for analysis and UI/dev exploration only

Remaining known import misses from the relaxed sample:

| Table | Issue |
|---|---|
| `dbo.__MigrationHistory` | sample has `NULL` for required `Model` |
| `dbo.sysdiagrams` | object is absent in the local schema |
| `dbo.tLogRequest_OT_Process` | some sample rows have `NULL` for required `StatusRetro` |
| `dbo.tRequest` | some sample rows have `NULL` for required `StatusRetro` |
| `service.tTemp_OTRequest` | some sample rows have `NULL` for required `CreatedAt` |

## Generate Export SQL

From the repo root:

```bash
./database/scripts/mssql/scripts/generate-seed-export-sql.sh
```

That produces:

- `database/schema/master/MAS_07_seed_export_queries.sql`

## Run Export SQL On Source Database

Run `MAS_07_seed_export_queries.sql` on the source MAS database that contains real data.

Expected outcome:

- one result set per manifest table
- `FULL` tables export all rows
- `SAMPLE` tables export `TOP (sample_limit)` rows
- `SKIP` tables are only commented in the generated SQL

## Convert Export Output Into Importable SQL

Best option:

- generate explicit `INSERT INTO ... VALUES ...` SQL from the source system

Acceptable option:

- export CSV files and bulk-load them later

Not recommended:

- relying on `MAS_05_top100_all_tables.txt` as-is, because it is human-readable output, not a clean import format

## Import Seed SQL Into Local Docker Database

If the importable SQL file is placed under `database/schema/master`, run:

```bash
./database/scripts/mssql/scripts/import-seed-file.sh database/schema/master/<your-seed-file.sql>
```

If the file is placed under `database/scripts/mssql/generated`, run:

```bash
./database/scripts/mssql/scripts/import-seed-file.sh database/scripts/mssql/generated/<your-seed-file.sql>
```

## Suggested First Real Seed

Use Tier `0` and Tier `1` first, then this bounded subset:

- `dbo.tEmployee`
- `dbo.tEmployee_LeaveQuota`
- `dbo.tTimeInOut`
- `dbo.tPayroll`
- `dbo.tPayroll_Detail`
- `dbo.tRequest`
- `dbo.tStage`

That gives a relationally useful sandbox without dragging in the entire production history.

## Known Gaps

- Current local Docker DB has the relaxed `MAS_09` sample seed loaded.
- Billing is intentionally excluded from the first pass.
- `TOP (100)` is good for shape validation, but not for coherent business flow validation. The next upgrade should be a period-scoped seed slice.
