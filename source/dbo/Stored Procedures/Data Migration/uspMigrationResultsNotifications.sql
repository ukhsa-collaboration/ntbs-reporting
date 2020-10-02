CREATE PROCEDURE [dbo].[uspMigrationResultsNotifications]
	@Region VARCHAR(50)		=	NULL,
	@MigrationRun INT = NULL
AS

	SELECT DATEPART(YEAR, NotificationDate) AS 'NotificationYear', LegacyRegion, COUNT(LegacyETSId) AS 'CountOfRecords' FROM [dbo].[MigrationRunResults]
	WHERE 
	MigrationRunId = @MigrationRun
	AND 
	(LegacyRegion = @Region
	OR
	GroupId IN 
		(SELECT DISTINCT GroupId FROM [dbo].[MigrationRunResults]
		 WHERE 
		 MigrationRunId = @MigrationRun
		 AND
	     LegacyRegion = @Region))
	GROUP BY DATEPART(YEAR, NotificationDate), LegacyRegion

	ORDER BY DATEPART(YEAR, NotificationDate) DESC

RETURN 0
