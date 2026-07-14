# MAS Analysis Roadmap

## What We Can Analyze Now

1. Schema inventory
   - table list, columns, PK/FK, defaults, indexes
   - schema ownership by module

2. Domain map
   - HR master data
   - attendance/timekeeping
   - payroll/tax/social security/PVF
   - leave and workflow
   - security/permissions
   - billing/custom modules

3. ER diagrams
   - official FK diagram
   - inferred relationship diagram from column naming
   - domain-specific diagrams instead of one huge unreadable ERD

4. Transaction volume analysis
   - master vs transaction vs log/staging classification
   - high-volume tables to prioritize for export/import

5. Stored procedure analysis
   - procedure groups by prefix: `sCAL_*`, `sBatch_*`, `sCreate_*`, `sUpdate*`, `sReport*`, `sMOD_*`
   - dependency graph between procedures, views, functions, and tables
   - identify core business logic for payroll, time, leave, workflow

6. Migration planning
   - split bounded contexts for .NET/PostgreSQL
   - identify legacy columns that should become normalized tables
   - identify computed/staging/log tables that should not be migrated as core domain

## What We Should Produce Next

Recommended next documents:

| Output | Purpose |
|---|---|
| `table-catalog.md` | Every table grouped by module with row counts and guessed meaning |
| `master-data-catalog.md` | Confirmed master/setup tables and their key columns |
| `transaction-catalog.md` | High-volume facts/logs/staging tables |
| `stored-procedure-map.md` | Procedure groups and likely workflows |
| `attendance-workflow.md` | Raw scan -> attendance calc -> payroll flow |
| `payroll-workflow.md` | Period -> time/pay components -> payroll -> tax/SSO/PVF |
| `leave-workflow.md` | Leave request -> approval -> quota -> attendance/payroll |
| `migration-slices.md` | Suggested .NET/PostgreSQL bounded contexts |

## Recommended Analysis Order

```text
1. Build table catalog from row counts + columns
2. Build domain-specific ER diagrams
3. Analyze attendance flow
4. Analyze payroll flow
5. Analyze leave/workflow flow
6. Generate sample seed script for only key tables
7. Draft migration model
```

## Good First Export Targets For Sample Data

The current `MAS_05_top100_all_tables.txt` is good for reading, but not direct insert. If we want a queryable sample database, export these first:

- `tCompany`
- `tSSO_Account`
- `tProject`
- `tSiteTR`
- `tBU1`, `tBU2`, `tBU3`, `tBU4`
- `tEmployee`
- `tEmployeeTitle`
- `tEmployeeStatus`
- `tPMPeriod`
- `tShift`
- `tWorkCalendar`, `tWorkCalendarDetail`
- `tTimeStamp` sample by date range
- `tTimeInOut` sample by date range
- `tPayroll`, `tPayroll_Detail`, `tPayroll_Tax`
- `tRequest`, `tStage`, `tFlow`, `tFlowPath`, `tRule`

Avoid exporting all rows from `tTimeStamp` and `tTimeInOut` initially; they are multi-million-row tables.
