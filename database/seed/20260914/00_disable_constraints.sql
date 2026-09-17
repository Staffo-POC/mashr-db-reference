USE [MAS]
GO

PRINT 'Disabling all foreign key constraints...';
EXEC sp_MSforeachtable 'ALTER TABLE ? NOCHECK CONSTRAINT ALL';
GO

PRINT 'Clearing existing seed data from target transaction tables...';
IF OBJECT_ID(N'dbo.tLOG_OTApprove', N'U') IS NOT NULL DELETE FROM [dbo].[tLOG_OTApprove];
IF OBJECT_ID(N'dbo.tTimeStamp', N'U') IS NOT NULL DELETE FROM [dbo].[tTimeStamp];
IF OBJECT_ID(N'dbo.tTimeInOut_AddLeave', N'U') IS NOT NULL DELETE FROM [dbo].[tTimeInOut_AddLeave];
IF OBJECT_ID(N'dbo.tTimeInOut', N'U') IS NOT NULL DELETE FROM [dbo].[tTimeInOut];
IF OBJECT_ID(N'dbo.tLogAddLeaveManagement', N'U') IS NOT NULL DELETE FROM [dbo].[tLogAddLeaveManagement];
IF OBJECT_ID(N'dbo.tRequest', N'U') IS NOT NULL DELETE FROM [dbo].[tRequest];
IF OBJECT_ID(N'dbo.tEmployee', N'U') IS NOT NULL DELETE FROM [dbo].[tEmployee];
GO
