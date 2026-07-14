-- Generated from database/schema/master/MAS_06_seed_manifest.csv
-- Purpose: run on the source MAS database to export a curated seed result set.
-- Notes:
--   1. FULL rows are exported without TOP.
--   2. SAMPLE rows use the manifest sample_limit.
--   3. SKIP rows are emitted as comments only.

PRINT N'===== FULL: dbo.tCompany (3 rows) =====';
SELECT N'dbo.tCompany' AS [__SourceTable], * FROM [dbo].[tCompany];
GO

PRINT N'===== FULL: dbo.tSSO_Account (3 rows) =====';
SELECT N'dbo.tSSO_Account' AS [__SourceTable], * FROM [dbo].[tSSO_Account];
GO

PRINT N'===== FULL: dbo.tProject (5 rows) =====';
SELECT N'dbo.tProject' AS [__SourceTable], * FROM [dbo].[tProject];
GO

PRINT N'===== FULL: dbo.tSiteTR (187 rows) =====';
SELECT N'dbo.tSiteTR' AS [__SourceTable], * FROM [dbo].[tSiteTR];
GO

PRINT N'===== FULL: dbo.tCostCenter (3 rows) =====';
SELECT N'dbo.tCostCenter' AS [__SourceTable], * FROM [dbo].[tCostCenter];
GO

PRINT N'===== SAMPLE: dbo.tBU1 (TOP 100 of 532) =====';
SELECT TOP (100) N'dbo.tBU1' AS [__SourceTable], * FROM [dbo].[tBU1];
GO

PRINT N'===== FULL: dbo.tBU2 (4 rows) =====';
SELECT N'dbo.tBU2' AS [__SourceTable], * FROM [dbo].[tBU2];
GO

PRINT N'===== FULL: dbo.tBU3 (1 rows) =====';
SELECT N'dbo.tBU3' AS [__SourceTable], * FROM [dbo].[tBU3];
GO

PRINT N'===== FULL: dbo.tBU4 (1 rows) =====';
SELECT N'dbo.tBU4' AS [__SourceTable], * FROM [dbo].[tBU4];
GO

PRINT N'===== FULL: dbo.tEmployeeStatusGroup (3 rows) =====';
SELECT N'dbo.tEmployeeStatusGroup' AS [__SourceTable], * FROM [dbo].[tEmployeeStatusGroup];
GO

PRINT N'===== FULL: dbo.tEmployeeStatus (3 rows) =====';
SELECT N'dbo.tEmployeeStatus' AS [__SourceTable], * FROM [dbo].[tEmployeeStatus];
GO

PRINT N'===== FULL: dbo.tEmployeeTitle (209 rows) =====';
SELECT N'dbo.tEmployeeTitle' AS [__SourceTable], * FROM [dbo].[tEmployeeTitle];
GO

PRINT N'===== FULL: dbo.tEmployeeLevel (14 rows) =====';
SELECT N'dbo.tEmployeeLevel' AS [__SourceTable], * FROM [dbo].[tEmployeeLevel];
GO

PRINT N'===== FULL: dbo.tEmployeeType1 (5 rows) =====';
SELECT N'dbo.tEmployeeType1' AS [__SourceTable], * FROM [dbo].[tEmployeeType1];
GO

PRINT N'===== FULL: dbo.tEmployeeType2 (1 rows) =====';
SELECT N'dbo.tEmployeeType2' AS [__SourceTable], * FROM [dbo].[tEmployeeType2];
GO

PRINT N'===== FULL: dbo.tEmployeeType3 (2 rows) =====';
SELECT N'dbo.tEmployeeType3' AS [__SourceTable], * FROM [dbo].[tEmployeeType3];
GO

PRINT N'===== FULL: dbo.tGender (3 rows) =====';
SELECT N'dbo.tGender' AS [__SourceTable], * FROM [dbo].[tGender];
GO

PRINT N'===== FULL: dbo.tNationality (3 rows) =====';
SELECT N'dbo.tNationality' AS [__SourceTable], * FROM [dbo].[tNationality];
GO

PRINT N'===== FULL: dbo.tPrefix (3 rows) =====';
SELECT N'dbo.tPrefix' AS [__SourceTable], * FROM [dbo].[tPrefix];
GO

PRINT N'===== FULL: dbo.tMartialStatus (5 rows) =====';
SELECT N'dbo.tMartialStatus' AS [__SourceTable], * FROM [dbo].[tMartialStatus];
GO

PRINT N'===== FULL: dbo.tShift (7 rows) =====';
SELECT N'dbo.tShift' AS [__SourceTable], * FROM [dbo].[tShift];
GO

PRINT N'===== FULL: dbo.tWorkCalendar (3 rows) =====';
SELECT N'dbo.tWorkCalendar' AS [__SourceTable], * FROM [dbo].[tWorkCalendar];
GO

PRINT N'===== SAMPLE: dbo.tWorkCalendarDetail (TOP 100 of 945) =====';
SELECT TOP (100) N'dbo.tWorkCalendarDetail' AS [__SourceTable], * FROM [dbo].[tWorkCalendarDetail];
GO

PRINT N'===== SAMPLE: dbo.tPMPeriod (TOP 100 of 150) =====';
SELECT TOP (100) N'dbo.tPMPeriod' AS [__SourceTable], * FROM [dbo].[tPMPeriod];
GO

PRINT N'===== FULL: dbo.tTaxRate (32 rows) =====';
SELECT N'dbo.tTaxRate' AS [__SourceTable], * FROM [dbo].[tTaxRate];
GO

PRINT N'===== FULL: dbo.tBankMaster (56 rows) =====';
SELECT N'dbo.tBankMaster' AS [__SourceTable], * FROM [dbo].[tBankMaster];
GO

PRINT N'===== FULL: dbo.tBankName (36 rows) =====';
SELECT N'dbo.tBankName' AS [__SourceTable], * FROM [dbo].[tBankName];
GO

PRINT N'===== FULL: dbo.tSSO_Hospital (27 rows) =====';
SELECT N'dbo.tSSO_Hospital' AS [__SourceTable], * FROM [dbo].[tSSO_Hospital];
GO

PRINT N'===== FULL: dbo.tSSO_ResignReason (7 rows) =====';
SELECT N'dbo.tSSO_ResignReason' AS [__SourceTable], * FROM [dbo].[tSSO_ResignReason];
GO


-- Tier 1

PRINT N'===== FULL: dbo.tUserGroup (7 rows) =====';
SELECT N'dbo.tUserGroup' AS [__SourceTable], * FROM [dbo].[tUserGroup];
GO

PRINT N'===== SAMPLE: dbo.tUser (TOP 87 of 87) =====';
SELECT TOP (87) N'dbo.tUser' AS [__SourceTable], * FROM [dbo].[tUser];
GO

PRINT N'===== FULL: dbo.tSYSUserRole (8 rows) =====';
SELECT N'dbo.tSYSUserRole' AS [__SourceTable], * FROM [dbo].[tSYSUserRole];
GO

PRINT N'===== FULL: dbo.tAssignUserRole (10 rows) =====';
SELECT N'dbo.tAssignUserRole' AS [__SourceTable], * FROM [dbo].[tAssignUserRole];
GO

PRINT N'===== FULL: dbo.tAssignMenuPermission (3 rows) =====';
SELECT N'dbo.tAssignMenuPermission' AS [__SourceTable], * FROM [dbo].[tAssignMenuPermission];
GO

PRINT N'===== FULL: dbo.tApproverList (24 rows) =====';
SELECT N'dbo.tApproverList' AS [__SourceTable], * FROM [dbo].[tApproverList];
GO

PRINT N'===== FULL: dbo.tRequestSystem (8 rows) =====';
SELECT N'dbo.tRequestSystem' AS [__SourceTable], * FROM [dbo].[tRequestSystem];
GO

PRINT N'===== FULL: dbo.tRequestType (43 rows) =====';
SELECT N'dbo.tRequestType' AS [__SourceTable], * FROM [dbo].[tRequestType];
GO

PRINT N'===== FULL: dbo.tRule (29 rows) =====';
SELECT N'dbo.tRule' AS [__SourceTable], * FROM [dbo].[tRule];
GO

PRINT N'===== FULL: dbo.tFlow (29 rows) =====';
SELECT N'dbo.tFlow' AS [__SourceTable], * FROM [dbo].[tFlow];
GO

PRINT N'===== FULL: dbo.tFlowPath (29 rows) =====';
SELECT N'dbo.tFlowPath' AS [__SourceTable], * FROM [dbo].[tFlowPath];
GO

PRINT N'===== FULL: dbo.tSelectApprover (60 rows) =====';
SELECT N'dbo.tSelectApprover' AS [__SourceTable], * FROM [dbo].[tSelectApprover];
GO


-- Tier 2

PRINT N'===== SAMPLE: dbo.tEmployee (TOP 100 of 21939) =====';
SELECT TOP (100) N'dbo.tEmployee' AS [__SourceTable], * FROM [dbo].[tEmployee];
GO

PRINT N'===== FULL: dbo.tEmployee_Children (10 rows) =====';
SELECT N'dbo.tEmployee_Children' AS [__SourceTable], * FROM [dbo].[tEmployee_Children];
GO

PRINT N'===== FULL: dbo.tEmployeeAbility (8 rows) =====';
SELECT N'dbo.tEmployeeAbility' AS [__SourceTable], * FROM [dbo].[tEmployeeAbility];
GO

PRINT N'===== FULL: dbo.tEmployeeWork_Quota (22 rows) =====';
SELECT N'dbo.tEmployeeWork_Quota' AS [__SourceTable], * FROM [dbo].[tEmployeeWork_Quota];
GO

PRINT N'===== SAMPLE: dbo.tEmployee_LeaveQuota (TOP 100 of 12087) =====';
SELECT TOP (100) N'dbo.tEmployee_LeaveQuota' AS [__SourceTable], * FROM [dbo].[tEmployee_LeaveQuota];
GO

PRINT N'===== SAMPLE: dbo.tEmployee_OtherCard (TOP 100 of 2282) =====';
SELECT TOP (100) N'dbo.tEmployee_OtherCard' AS [__SourceTable], * FROM [dbo].[tEmployee_OtherCard];
GO

PRINT N'===== SAMPLE: dbo.tEmployee_RateP0x (TOP 100 of 8773) =====';
SELECT TOP (100) N'dbo.tEmployee_RateP0x' AS [__SourceTable], * FROM [dbo].[tEmployee_RateP0x];
GO

PRINT N'===== SAMPLE: dbo.tEmployeePhoto (TOP 50 of 16440) =====';
SELECT TOP (50) N'dbo.tEmployeePhoto' AS [__SourceTable], * FROM [dbo].[tEmployeePhoto];
GO


-- Tier 3

PRINT N'===== FULL: dbo.tAssignWorkCalendar (1 rows) =====';
SELECT N'dbo.tAssignWorkCalendar' AS [__SourceTable], * FROM [dbo].[tAssignWorkCalendar];
GO

PRINT N'===== SAMPLE: dbo.tTimeStamp (TOP 100 of 7377898) =====';
SELECT TOP (100) N'dbo.tTimeStamp' AS [__SourceTable], * FROM [dbo].[tTimeStamp];
GO

PRINT N'===== SAMPLE: dbo.tTimeInOut (TOP 100 of 3551128) =====';
SELECT TOP (100) N'dbo.tTimeInOut' AS [__SourceTable], * FROM [dbo].[tTimeInOut];
GO

PRINT N'===== SAMPLE: dbo.tTimeInOut_Data (TOP 100 of 1420276) =====';
SELECT TOP (100) N'dbo.tTimeInOut_Data' AS [__SourceTable], * FROM [dbo].[tTimeInOut_Data];
GO

PRINT N'===== SAMPLE: dbo.tTimeInOut_AddLeave (TOP 100 of 726553) =====';
SELECT TOP (100) N'dbo.tTimeInOut_AddLeave' AS [__SourceTable], * FROM [dbo].[tTimeInOut_AddLeave];
GO

PRINT N'===== SAMPLE: dbo.tTimeSheet_MultiPeriod (TOP 100 of 0) =====';
SELECT TOP (100) N'dbo.tTimeSheet_MultiPeriod' AS [__SourceTable], * FROM [dbo].[tTimeSheet_MultiPeriod];
GO


-- Tier 4

PRINT N'===== SAMPLE: dbo.tPayroll (TOP 100 of 147616) =====';
SELECT TOP (100) N'dbo.tPayroll' AS [__SourceTable], * FROM [dbo].[tPayroll];
GO

PRINT N'===== SAMPLE: dbo.tPayroll_Detail (TOP 100 of 147670) =====';
SELECT TOP (100) N'dbo.tPayroll_Detail' AS [__SourceTable], * FROM [dbo].[tPayroll_Detail];
GO

PRINT N'===== SAMPLE: dbo.tPayroll_Tax (TOP 100 of 147619) =====';
SELECT TOP (100) N'dbo.tPayroll_Tax' AS [__SourceTable], * FROM [dbo].[tPayroll_Tax];
GO

PRINT N'===== SAMPLE: dbo.tPayroll_Allowance (TOP 100 of 147616) =====';
SELECT TOP (100) N'dbo.tPayroll_Allowance' AS [__SourceTable], * FROM [dbo].[tPayroll_Allowance];
GO

PRINT N'===== SAMPLE: dbo.tPayroll_Welfare (TOP 100 of 88692) =====';
SELECT TOP (100) N'dbo.tPayroll_Welfare' AS [__SourceTable], * FROM [dbo].[tPayroll_Welfare];
GO

PRINT N'===== SAMPLE: dbo.tTax91 (TOP 100 of 22105) =====';
SELECT TOP (100) N'dbo.tTax91' AS [__SourceTable], * FROM [dbo].[tTax91];
GO

PRINT N'===== SAMPLE: dbo.tPayroll_ColDef (TOP 100 of 1790) =====';
SELECT TOP (100) N'dbo.tPayroll_ColDef' AS [__SourceTable], * FROM [dbo].[tPayroll_ColDef];
GO

PRINT N'===== SAMPLE: dbo.tColDef_PayrollExport (TOP 100 of 1584) =====';
SELECT TOP (100) N'dbo.tColDef_PayrollExport' AS [__SourceTable], * FROM [dbo].[tColDef_PayrollExport];
GO

PRINT N'===== FULL: dbo.tColDef_PayrollFormat (6 rows) =====';
SELECT N'dbo.tColDef_PayrollFormat' AS [__SourceTable], * FROM [dbo].[tColDef_PayrollFormat];
GO


-- Tier 5

PRINT N'===== SAMPLE: dbo.tRequest (TOP 100 of 7107) =====';
SELECT TOP (100) N'dbo.tRequest' AS [__SourceTable], * FROM [dbo].[tRequest];
GO

PRINT N'===== SAMPLE: dbo.tStage (TOP 100 of 9568) =====';
SELECT TOP (100) N'dbo.tStage' AS [__SourceTable], * FROM [dbo].[tStage];
GO

PRINT N'===== SAMPLE: dbo.tRequest_byAdmin (TOP 100 of 4074) =====';
SELECT TOP (100) N'dbo.tRequest_byAdmin' AS [__SourceTable], * FROM [dbo].[tRequest_byAdmin];
GO

PRINT N'===== SAMPLE: customize.tSCC_TranferSite (TOP 100 of 10657) =====';
SELECT TOP (100) N'customize.tSCC_TranferSite' AS [__SourceTable], * FROM [customize].[tSCC_TranferSite];
GO

PRINT N'===== SAMPLE: customize.tSCC_TranferEmp (TOP 100 of 10657) =====';
SELECT TOP (100) N'customize.tSCC_TranferEmp' AS [__SourceTable], * FROM [customize].[tSCC_TranferEmp];
GO

PRINT N'===== SAMPLE: customize.tSCC_TranferApprove (TOP 100 of 10657) =====';
SELECT TOP (100) N'customize.tSCC_TranferApprove' AS [__SourceTable], * FROM [customize].[tSCC_TranferApprove];
GO


-- Tier 6

PRINT N'===== FULL: dbo.tSysConfig (6 rows) =====';
SELECT N'dbo.tSysConfig' AS [__SourceTable], * FROM [dbo].[tSysConfig];
GO

PRINT N'===== FULL: dbo.tSysParm (58 rows) =====';
SELECT N'dbo.tSysParm' AS [__SourceTable], * FROM [dbo].[tSysParm];
GO

PRINT N'===== FULL: dbo.tSysSettings (2 rows) =====';
SELECT N'dbo.tSysSettings' AS [__SourceTable], * FROM [dbo].[tSysSettings];
GO

PRINT N'===== SAMPLE: dbo.tSYS_WebMenu (TOP 100 of 126) =====';
SELECT TOP (100) N'dbo.tSYS_WebMenu' AS [__SourceTable], * FROM [dbo].[tSYS_WebMenu];
GO

PRINT N'===== SAMPLE: dbo.tSYSOutPayMenu (TOP 100 of 113) =====';
SELECT TOP (100) N'dbo.tSYSOutPayMenu' AS [__SourceTable], * FROM [dbo].[tSYSOutPayMenu];
GO

PRINT N'===== FULL: dbo.tReportNormal_Config (46 rows) =====';
SELECT N'dbo.tReportNormal_Config' AS [__SourceTable], * FROM [dbo].[tReportNormal_Config];
GO

PRINT N'===== FULL: dbo.tReportNormal_Language (46 rows) =====';
SELECT N'dbo.tReportNormal_Language' AS [__SourceTable], * FROM [dbo].[tReportNormal_Language];
GO

PRINT N'===== FULL: customize.tInfoExportGroup (6 rows) =====';
SELECT N'customize.tInfoExportGroup' AS [__SourceTable], * FROM [customize].[tInfoExportGroup];
GO

PRINT N'===== FULL: customize.tInfoExportGroupDetail (87 rows) =====';
SELECT N'customize.tInfoExportGroupDetail' AS [__SourceTable], * FROM [customize].[tInfoExportGroupDetail];
GO

PRINT N'===== FULL: customize.tMOD_LogSetting (179 rows) =====';
SELECT N'customize.tMOD_LogSetting' AS [__SourceTable], * FROM [customize].[tMOD_LogSetting];
GO

PRINT N'===== FULL: customize.tSCC_AprvSite (141 rows) =====';
SELECT N'customize.tSCC_AprvSite' AS [__SourceTable], * FROM [customize].[tSCC_AprvSite];
GO

PRINT N'===== FULL: customize.tSCC_SettingPayAllowance (2 rows) =====';
SELECT N'customize.tSCC_SettingPayAllowance' AS [__SourceTable], * FROM [customize].[tSCC_SettingPayAllowance];
GO


-- Tier 9

-- SKIP billing.tClient (0 rows) - billing gap no usable current metadata

-- SKIP billing.tContractor (0 rows) - billing gap no usable current metadata

-- SKIP billing.tAllowance (0 rows) - billing gap no usable current metadata

-- SKIP billing.tProjectCost (0 rows) - billing gap no usable current metadata

