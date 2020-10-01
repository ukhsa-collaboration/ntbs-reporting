CREATE PROCEDURE [dbo].[uspMigrationResultsNotifications]
	@Region VARCHAR(50)		=	NULL,
	@MigrationRun INT = NULL
AS

	SELECT DATEPART(YEAR, NotificationDate) AS 'NotificationYear', OriginalRegion, COUNT(LegacyETSId) AS 'CountOfRecords' FROM [dbo].[MigrationRunResults]
	WHERE 
	MigrationRunId = @MigrationRun
	AND 
	(OriginalRegion = @Region
	OR
	GroupId IN 
		(SELECT DISTINCT GroupId FROM [dbo].[MigrationRunResults]
		 WHERE 
		 MigrationRunId = @MigrationRun
		 AND
	     OriginalRegion = @Region))
	GROUP BY DATEPART(YEAR, NotificationDate), OriginalRegion

	ORDER BY DATEPART(YEAR, NotificationDate) DESC

RETURN 0
