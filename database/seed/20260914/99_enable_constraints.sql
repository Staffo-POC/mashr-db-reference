USE [MAS]
GO

PRINT 'Re-enabling all foreign key constraints...';
EXEC sp_MSforeachtable 'ALTER TABLE ? WITH NOCHECK CHECK CONSTRAINT ALL';
GO
