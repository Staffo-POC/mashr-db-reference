USE [MAS]
GO

PRINT 'Disabling all foreign key constraints...';
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

PRINT 'Clearing existing data from target tables...';
DELETE FROM [customize].[tMOD_LogSetting];
DELETE FROM [customize].[tSCC_AprvSite];
DELETE FROM [dbo].[tBU1];
DELETE FROM [dbo].[tBU1_New];
DELETE FROM [dbo].[tColDef_PayrollExport];
DELETE FROM [dbo].[tColDef_rEmployeeExport];
DELETE FROM [dbo].[tColDef_rEmployeeExportNew];
DELETE FROM [dbo].[tEmployeeTitle];
DELETE FROM [dbo].[tPayroll_ColDef];
DELETE FROM [dbo].[tPayroll_GLAccNo];
DELETE FROM [dbo].[tPayroll_GLAccNoRow];
DELETE FROM [dbo].[tReport_name];
DELETE FROM [dbo].[tResignReason];
DELETE FROM [dbo].[tSiteTR];
DELETE FROM [dbo].[tSYS_WebMenu];
DELETE FROM [dbo].[tSYSOutPayMenu];
DELETE FROM [dbo].[tSYSOutPayMenuAdvance];
DELETE FROM [dbo].[tTimeInOut_ColDef];
GO
