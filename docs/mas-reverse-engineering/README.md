# MAS Reverse Engineering Notes

Status: reference/working notes. For the current concise documentation set, start at [MAS DB Analysis MVP](../MAS-DB-Analysis-MVP/README.md).

This folder captures the current understanding of the MAS HR database from:

- Local Docker MSSQL: `localhost,14333`, database `MAS`
- Schema package: `database/schema/master`
- Metadata package: `database/metadata/export-20260713`
- Sample result text: `database/schema/master/MAS_05_top100_all_tables.txt`

Current Docker import status:

| Object type | Count |
|---|---:|
| Tables | 570 |
| Views | 437 |
| Stored procedures | 399 |
| Functions | 209 |

Current seed status: the Docker database has the relaxed `MAS_09` sample seed loaded from `MAS_05_top100_all_tables.txt` as of 2026-07-13. This seeded 288 tables / 14,232 rows from 290 text-export sections. It is sample data only; large tables are normally limited to the exported `TOP 100` rows. Production row counts come from `database/metadata/export-20260713/05_row_counts.csv`.

## First Read

- [01-domain-map.md](./01-domain-map.md) - domain/module map and master/transaction/log candidates
- [02-er-mermaid.md](./02-er-mermaid.md) - first-pass relationship diagrams in Mermaid
- [03-analysis-roadmap.md](./03-analysis-roadmap.md) - what else we can analyze
- [04-mcp-local-mssql.md](./04-mcp-local-mssql.md) - local MSSQL/MCP connection notes
- [05-table-relationship-analysis.md](./05-table-relationship-analysis.md) - all-table catalog, relationship analysis, master-data coverage, views, and Mermaid diagrams
- [06-seed-data-plan.md](./06-seed-data-plan.md) - recommended seed bundles, load order, and what to skip first
- [07-seed-runbook.md](./07-seed-runbook.md) - generate export SQL, obtain importable seed data, and load it into local Docker MSSQL
- [08-relationship-mermaid.md](./08-relationship-mermaid.md) - diagram-only Mermaid relationship maps for rendering, entities colored by table category
- [09-data-count-summary.md](./09-data-count-summary.md) - row-count snapshot and master-data candidates by domain
- [10-table-categories.md](./10-table-categories.md) - full 570+ table catalog classified into Master/Config, Entity/Account, Transaction/Fact, Log/Audit, Temp/Staging, System/Internal, Other/Unclear
- `database/schema/master/MAS_08_seed_from_top100.sql` - first-wave repo-local seed built from the sample text export
- `database/schema/master/MAS_09_seed_all_top100_relaxed.sql` - broader analysis seed from all parseable `MAS_05` sample sections

## Main Finding

MAS is not only payroll. It looks like a broad HR/back-office system with these major areas:

- Employee master and organization structure
- Attendance/timekeeping
- Payroll, tax, SSO, PVF/GPF
- Leave and workflow approval
- Shift/work calendar
- User/security/permissions
- Mobile/service integration
- Billing/project cost features
- Custom SCC/Tropical incentive/site-transfer extensions
