CREATE PROCEDURE [dbo].[uspMigrationSelectedNotificationsByYear]
	@Region VARCHAR(50)		=	NULL
AS
	SELECT NotificationYear, COUNT(OldNotificationId) AS CountOfRecords
	FROM [dbo].[MigrationMasterList] 
	WHERE Region = @Region
	AND [NotificationDate] >= '2017-01-01'
	GROUP BY NotificationYear
	ORDER BY NotificationYear
RETURN 0
