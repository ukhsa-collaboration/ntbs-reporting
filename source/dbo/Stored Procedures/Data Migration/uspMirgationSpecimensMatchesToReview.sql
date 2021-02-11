CREATE PROCEDURE [dbo].[uspMirgationSpecimensMatchesToReview]
	@MigrationRun INT = NULL
AS
	SELECT 
		[MigrationNotificationId]			AS 'MigrationNotificationId' 
		--,[NotificationDate]					AS 'NotificationDate' 
		--,DATEPART(YEAR, NotificationDate)	AS 'NotificationYear'
		,[LegacyETSId]						AS 'EtsId'
		,d.MigrationNotes					AS 'Comments'
 
		FROM [dbo].[MigrationRunResults] mrr
		INNER JOIN [dbo].[vwMigrationDubiousSpecimenMatches] d on d.EtsId = mrr.LegacyETSId
		WHERE MigrationRunId = @MigrationRun
