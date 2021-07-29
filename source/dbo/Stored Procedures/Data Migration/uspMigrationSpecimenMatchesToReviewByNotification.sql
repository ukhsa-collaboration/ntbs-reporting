CREATE PROCEDURE [dbo].[uspMigrationSpecimenMatchesToReviewByNotification]
	@MigrationRun INT = NULL
AS
	SELECT 
		[MigrationNotificationId]			AS 'MigrationNotificationId'
		,[LegacyETSId]						AS 'EtsId'
		,d.MigrationNotes					AS 'Comments'
 
		FROM [dbo].[MigrationRunResults] mrr
		INNER JOIN [dbo].[vwMigrationDubiousSpecimenMatches] d on d.EtsId = mrr.LegacyETSId
		WHERE MigrationRunId = @MigrationRun
