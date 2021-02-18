CREATE PROCEDURE [dbo].[uspMigrationResultsNotifications]
	@MigrationRun INT = NULL
AS
	WITH GroupedNotifications AS
	(SELECT GroupId, STRING_AGG(MigrationNotificationId, ', ') AS 'Linked notifications'
	FROM [dbo].[MigrationRunResults]
		WHERE MigrationRunId = @MigrationRun
		AND GroupId IS NOT NULL
		GROUP BY GroupId)

	SELECT 
		[MigrationNotificationId]			AS 'MigrationNotificationId' 
		,[NotificationDate]					AS 'NotificationDate' 
		,DATEPART(YEAR, NotificationDate)	AS 'NotificationYear'
		,[LegacyETSId]						AS 'EtsId'
		,[LegacyLtbrNo]						AS 'LtbrNo'
		,[SourceSystem]						AS 'Record sourced from'
		,[LegacyHospitalName]				AS 'Legacy Hospital name'
		,[EtsTreatmentOutcome]				AS 'Ets Treatment outcome'
		,[ProxyTestDateUsed]				AS 'Proxy test date used'
		,[NTBSNotificationId]				AS 'NTBS Id'
		,[TBServiceName]					AS 'TB Service'
		,[NTBSHospitalName]					AS 'NTBS Hospital name'
		,[NTBSRegion]						AS 'NTBS Region'
		,[NTBSTreatmentOutcome]				AS 'NTBS Treatment outcome'
		,[NTBSCaseManagerUsername]			AS 'NTBS Case manager username'
		,[MigrationResult]					AS 'Migration Result'
		,[MigrationNotes]					AS 'Comments'
		,[MigrationAlerts]					AS 'Migration Alerts'
		,g.[Linked notifications]			AS 'Linked notifications'

		FROM [dbo].[MigrationRunResults] mrr
			LEFT OUTER JOIN GroupedNotifications g ON g.GroupId = mrr.GroupId
		WHERE MigrationRunId = @MigrationRun
		ORDER BY [NotificationDate] DESC

RETURN 0
