CREATE PROCEDURE [dbo].[uspMigrationAdditionalNotificationsByRegionAndYear]
	@Region VARCHAR(50)		=	NULL
AS


	--we want to display a list of the additional notifications which will be migrated as part of a particular region's migration.
	--these are records linked to the selected notifications, which may be outside the chosen the region



	
	SELECT NotificationYear, Region, COUNT(OldNotificationId) AS 'CountOfRecords' FROM [dbo].[MigrationMasterList] 
	WHERE GroupId IN
	(SELECT DISTINCT GroupId FROM [dbo].[MigrationMasterList] 
	WHERE Region = @Region
	AND [NotificationDate] >= '2017-01-01'
	AND GroupId IS NOT NULL)
	AND
	OldNotificationId NOT IN
	(SELECT OldNotificationId FROM [dbo].[MigrationMasterList] 
	WHERE Region = @Region
	AND [NotificationDate] >= '2017-01-01')

	
	GROUP BY NotificationYear, Region
	ORDER BY NotificationYear, Region
RETURN 0
