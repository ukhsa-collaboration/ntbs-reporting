CREATE PROCEDURE [dbo].[uspMigrationRunsForRegion]
	@Region VARCHAR(50)		=	NULL
AS

	
	SELECT mr.MigrationRunId, CONCAT(MigrationRunDate, ': ', MigrationRunName) AS 'MigrationDescription' 
	FROM [MigrationRun] mr
	WHERE mr.LeadRegion = @Region

RETURN 0
