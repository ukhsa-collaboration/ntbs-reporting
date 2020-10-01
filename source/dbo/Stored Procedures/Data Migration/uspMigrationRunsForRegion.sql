CREATE PROCEDURE [dbo].[uspMigrationRunsForRegion]
	@Region VARCHAR(50)		=	NULL
AS
	SELECT mr.MigrationRunId, CONCAT(MigrationRunDate, ': ', MigrationRunName) AS 'MigrationDescription' FROM [MigrationRun] mr
	INNER JOIN [MigrationRunRegion] mrr ON mrr.MigrationRunId = mr.MigrationRunId
	AND mrr.MigrationRunRegionName = @Region

RETURN 0
