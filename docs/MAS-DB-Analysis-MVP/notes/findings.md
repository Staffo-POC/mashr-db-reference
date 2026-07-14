# Findings

## Metadata Inputs

- `database/metadata/export-20260713/` is the authoritative metadata source.
- `docs/MAS-DB-Analysis-MVP/` contains generated documentation, Mermaid source, and SVG images.
- CSV and SQL metadata should not be duplicated into the docs folder.
- No SQL was modified.
- No relationships were invented in Mermaid ER diagrams.

## Coverage

| Metric | Count |
|---|---:|
| Tables | 572 |
| Columns | 16,216 |
| Declared FK rows | 56 |
| Schemas | 8 |

## Schema Distribution

| Schema | Tables |
|---|---:|
| `dbo` | 487 |
| `service` | 27 |
| `billing` | 20 |
| `customize` | 19 |
| `rosetta` | 8 |
| `license` | 5 |
| `payroll` | 5 |
| `maspayroll` | 1 |

## Main Discoveries

- FK coverage is sparse compared with table count.
- `dbo.tEmployee` is the most central declared parent table, with 14 inbound FK rows.
- Attendance/timekeeping is the largest data area by exported row counts.
- Workflow has comparatively strong declared FK coverage around request/rule/flow/stage.
- Payroll has declared links from employee and payroll period into `tPayroll`, but exported metadata does not include FK rows from payroll detail/tax/allowance tables back to `tPayroll`.
- Billing has 20 metadata tables, zero exported row counts, and no exported PK/FK relationships.

## Top Row-Count Tables

| Table | Rows |
|---|---:|
| `dbo.tTimeStamp` | 7,377,898 |
| `dbo.tTimeInOut` | 3,551,128 |
| `dbo.tLOG_EmployeeGUID` | 1,984,978 |
| `dbo.tTimeInOut_Data` | 1,420,276 |
| `dbo.tLOG_OTApprove` | 1,235,090 |
| `dbo.tLOG_EmployeeText` | 1,077,517 |
| `dbo.tTimeInOut_AddLeave` | 726,536 |
| `dbo.tLOG_TimeInOut` | 402,565 |
| `dbo.tTempBatchTime` | 231,794 |
| `dbo.tPayroll_Detail` | 147,670 |

## Constraint Caveats

- Mermaid diagrams represent exported FK constraints only.
- Business flows in prose are descriptive and should not be treated as database constraints.
- Any migration or API contract should validate missing natural-key relationships with data profiling queries.

## Generated Outputs

- Mermaid Markdown diagrams: `docs/MAS-DB-Analysis-MVP/diagrams/`
- Extracted Mermaid source: `docs/MAS-DB-Analysis-MVP/mermaid/`
- Rendered SVG diagrams: `docs/MAS-DB-Analysis-MVP/images/`
