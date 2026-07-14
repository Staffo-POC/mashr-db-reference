# MAS Seed Data Plan

This plan turns the existing sample/export metadata into a practical seed strategy for a queryable local analysis database.

Important constraint:

- The current local Docker MSSQL database contains schema only.
- Production row counts come from `database/metadata/export-20260713/05_row_counts.csv`.
- Existing sample/export intent comes from `database/schema/master/MAS_04_sample_data_queries.sql`.
- Billing tables are still a gap because current metadata shows zero production rows and no PK/FK metadata.

## Goal

Build a small but relationally useful seed set that lets us:

- inspect master data with real values
- validate inferred relationships
- trace attendance -> payroll -> workflow flows
- avoid importing multi-million-row raw fact tables in full

## Seeding Rules

1. Seed stable master/setup tables in full.
2. Seed workflow/security reference tables in full.
3. Seed medium transaction tables with `TOP (100)` or another bounded sample first.
4. Seed very large attendance/payroll facts with a date-filtered subset later, not full table dumps.
5. Skip log/temp/staging tables unless they are required to explain a specific workflow.
6. Treat billing as a separate export task because current package does not prove usable data exists.

## Recommended Order

### Tier 0: Core master data

Seed these first with full rows:

- `dbo.tCompany`
- `dbo.tSSO_Account`
- `dbo.tProject`
- `dbo.tSiteTR`
- `dbo.tCostCenter`
- `dbo.tBU1`
- `dbo.tBU2`
- `dbo.tBU3`
- `dbo.tBU4`
- `dbo.tEmployeeStatusGroup`
- `dbo.tEmployeeStatus`
- `dbo.tEmployeeTitle`
- `dbo.tEmployeeLevel`
- `dbo.tEmployeeType1`
- `dbo.tEmployeeType2`
- `dbo.tEmployeeType3`
- `dbo.tGender`
- `dbo.tNationality`
- `dbo.tPrefix`
- `dbo.tMartialStatus`
- `dbo.tShift`
- `dbo.tWorkCalendar`
- `dbo.tWorkCalendarDetail`
- `dbo.tPMPeriod`
- `dbo.tTaxRate`
- `dbo.tBankMaster`
- `dbo.tBankName`
- `dbo.tSSO_Hospital`
- `dbo.tSSO_ResignReason`

Why this tier matters:

- It gives us the master keys behind employee, site, project, shift, calendar, and payroll period.
- Most inferred relationships point back into this tier.

### Tier 1: Security and workflow reference

Seed these in full:

- `dbo.tUserGroup`
- `dbo.tUser`
- `dbo.tSYSUserRole`
- `dbo.tAssignUserRole`
- `dbo.tAssignMenuPermission`
- `dbo.tApproverList`
- `dbo.tApproverGroup`
- `dbo.tRequestSystem`
- `dbo.tRequestType`
- `dbo.tRule`
- `dbo.tFlow`
- `dbo.tFlowPath`
- `dbo.tSelectApprover`
- `dbo.tUseList`
- `dbo.tUse_Flow`

Why this tier matters:

- This is the cleanest FK-declared workflow area in the schema.
- It supports request/approval analysis without needing large fact volumes.

### Tier 2: Employee-centered transactional seed

Seed these with bounded samples first:

- `dbo.tEmployee` : start with `TOP (100)`
- `dbo.tEmployee_Children` : full
- `dbo.tEmployeeAbility` : full
- `dbo.tEmployeeWork_Quota` : full
- `dbo.tEmployee_LeaveQuota` : `TOP (100)`
- `dbo.tEmployee_OtherCard` : `TOP (100)`
- `dbo.tEmployee_RateP0x` : `TOP (100)`
- `dbo.tEmployeePhoto` : `TOP (50)` or skip if image payload is annoying

Why this tier matters:

- It gives us realistic employee records and enough related rows to validate joins and profile views.

### Tier 3: Attendance seed

Seed these with bounded samples only:

- `dbo.tTimeStamp` : `TOP (100)` now, later switch to date-filter sample
- `dbo.tTimeInOut` : `TOP (100)` now, later switch to date-filter sample
- `dbo.tTimeInOut_Data` : `TOP (100)`
- `dbo.tTimeInOut_AddLeave` : `TOP (100)`
- `dbo.tAssignWorkCalendar` : full
- `dbo.tAssignShift` : if available from source, bounded sample
- `dbo.tAssignShiftByWeekDay` : if available from source, bounded sample
- `dbo.tTimeSheet_MultiPeriod` : bounded sample

Best later upgrade:

- export one payroll period or one month for a small employee subset instead of raw `TOP (100)`

### Tier 4: Payroll seed

Seed these with bounded samples:

- `dbo.tPayroll` : `TOP (100)`
- `dbo.tPayroll_Detail` : `TOP (100)`
- `dbo.tPayroll_Tax` : `TOP (100)`
- `dbo.tPayroll_Allowance` : `TOP (100)`
- `dbo.tPayroll_Welfare` : `TOP (100)`
- `dbo.tTax91` : `TOP (100)`
- `dbo.tPayroll_ColDef` : full
- `dbo.tColDef_PayrollExport` : `TOP (100)` is enough initially
- `dbo.tColDef_PayrollFormat` : full

Why this tier matters:

- This is enough to understand payroll shape, line items, and period linkage without dragging in the entire payroll history.

### Tier 5: Request / approval transactions

Seed these with bounded samples:

- `dbo.tRequest` : `TOP (100)`
- `dbo.tStage` : `TOP (100)`
- `dbo.tRequest_byAdmin` : `TOP (100)`
- `customize.tSCC_TranferSite` : `TOP (100)`
- `customize.tSCC_TranferEmp` : `TOP (100)`
- `customize.tSCC_TranferApprove` : `TOP (100)`

Why this tier matters:

- It lets us test the workflow engine with real request rows without pulling all logs.

### Tier 6: Optional useful small config tables

Seed these in full if we want better UX/report coverage:

- `dbo.tSysConfig`
- `dbo.tSysParm`
- `dbo.tSysSettings`
- `dbo.tSYS_WebMenu`
- `dbo.tSYSOutPayMenu`
- `dbo.tReportNormal_Config`
- `dbo.tReportNormal_Language`
- `customize.tInfoExportGroup`
- `customize.tInfoExportGroupDetail`
- `customize.tMOD_LogSetting`
- `customize.tSCC_AprvSite`
- `customize.tSCC_SettingPayAllowance`

## Do Not Seed First

Avoid these in the first pass:

- `dbo.tLOG_*`
- `dbo.tTemp*`
- `service.tTemp_*`
- `rosetta.*`
- `billing.*`

Reason:

- They are either large logs, staging artifacts, device sync remnants, or currently unsupported by good metadata.

## Best Next Upgrade

After the first seed is working, replace `TOP (100)` with a coherent slice:

- one `PMPeriod_ID`
- one or two `Site_ID`
- 20 to 50 employees
- matching attendance, payroll, request, and leave rows only for that slice

That gives a much better analysis dataset than arbitrary top rows.

## Recommended Deliverables

Use [MAS_06_seed_manifest.csv](database/schema/master/MAS_06_seed_manifest.csv) as the execution checklist.

If we continue, the best next implementation is:

1. generate a curated SQL export query file from the manifest
2. export result sets from the source MSSQL
3. convert those rows into insert scripts or CSV load files
4. import them into the local Docker analysis database
