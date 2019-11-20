USE [NTBS_R1_Reporting_Staging]
GO

DECLARE @RC int
EXECUTE @RC = [dbo].[uspGenerate] 
GO
