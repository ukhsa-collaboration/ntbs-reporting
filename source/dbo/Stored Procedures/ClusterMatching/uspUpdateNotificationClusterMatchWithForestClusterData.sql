CREATE PROCEDURE [dbo].[uspUpdateNotificationClusterMatchWithForestClusterData]
AS
	
	BEGIN TRY
		DECLARE @TableName varchar(100)
		SELECT TOP 1 @TableName=[table_name]
		FROM information_schema.tables
		WHERE table_name LIKE 'FOREST ETS Cluster IDs Build%'

		-- Split by space and get last string as a build number
		DECLARE @BuildNumber int
		SELECT @BuildNumber=REVERSE(LEFT(REVERSE(@TableName), CHARINDEX(' ',REVERSE(@TableName))- 1))

		-- Delete Entries from Notification Cluster Match table
		DELETE FROM [dbo].NotificationClusterMatch

		-- Populate Notification Cluster Match table with data from 
		INSERT INTO NotificationClusterMatch (NotificationId, ClusterId) 
		EXEC('SELECT forestCluster.ETSCaseId_max, forestCluster.smallest_clusterLabel
			FROM [dbo].['+ @TableName + '] forestCluster
			JOIN 
			(SELECT smallest_clusterLabel
			FROM [dbo].['+ @TableName + '] 
			WHERE smallest_clusterLabel IS NOT NULL AND ETSCaseId_max IS NOT NULL
			GROUP BY smallest_clusterLabel
			HAVING COUNT(*) > 1) clusters ON clusters.smallest_clusterLabel = forestCluster.smallest_clusterLabel
			WHERE forestCluster.smallest_clusterLabel IS NOT NULL AND forestCluster.ETSCaseId_max IS NOT NULL
		')

		-- Update build number
		IF EXISTS (SELECT * FROM ForestClusterBuild)
			UPDATE ForestClusterBuild SET BuildNumber = @BuildNumber
		ELSE
			INSERT INTO ForestClusterBuild (BuildNumber) Values (@BuildNumber);
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
