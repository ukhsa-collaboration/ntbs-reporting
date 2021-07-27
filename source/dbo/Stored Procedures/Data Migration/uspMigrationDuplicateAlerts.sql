CREATE PROCEDURE [dbo].[uspMigrationDuplicateAlerts]
	@MigrationRun INT = NULL
AS
	SELECT
		mrr.MigrationNotificationId												AS 'MigrationNotificationId',
		mrr.LegacyETSId															AS 'EtsId',
		mrr.NTBSNotificationId													AS 'NtbsId',
		mrr.NotificationDate													AS 'NotificationDate',
		mrr.TBServiceName														AS 'TbService',
		duplicate.NotificationId												AS 'DuplicateNtbsId',
		duplicate.NotificationDate												AS 'DuplicateNotificationDate',
		ABS(DATEDIFF(day, mrr.NotificationDate, duplicate.NotificationDate))	AS 'DaysBetweenNotifications'
	FROM [dbo].[MigrationRunResults] mrr
		INNER JOIN [$(NTBS)].[dbo].[Alert] a on a.NotificationId = mrr.NTBSNotificationId
		LEFT JOIN [$(NTBS)].[dbo].[Notification] duplicate on duplicate.NotificationId = a.DuplicateId
	WHERE AlertStatus = 'Open'
		AND AlertType = 'DataQualityPotientialDuplicate'
		AND mrr.MigrationRunId = @MigrationRun