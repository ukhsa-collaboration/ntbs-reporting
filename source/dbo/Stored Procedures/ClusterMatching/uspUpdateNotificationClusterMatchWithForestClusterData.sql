﻿CREATE PROCEDURE [dbo].[uspUpdateNotificationClusterMatchWithForestClusterData]
(
	@BuildNumber VARCHAR(10)
)
AS
	BEGIN TRY
		-- Delete Entries from Notification Cluster Match table
		TRUNCATE TABLE [dbo].NotificationClusterMatch

		-- Populate Notification Cluster Match table with data from 
		INSERT INTO NotificationClusterMatch (NotificationId, ClusterId) 
		SELECT forestCluster.ETSCaseId_max, 
			forestCluster.smallest_clusterLabel
		FROM [dbo].[ForestEtsCluster] forestCluster
		JOIN (
			SELECT smallest_clusterLabel
			FROM [dbo].[ForestEtsCluster] 
			WHERE COALESCE(smallest_clusterLabel,'') <> '' AND COALESCE(ETSCaseId_max,'') <> ''
			GROUP BY smallest_clusterLabel
			HAVING COUNT(*) > 1
		) clusters 
		ON clusters.smallest_clusterLabel = forestCluster.smallest_clusterLabel
		WHERE COALESCE(forestCluster.smallest_clusterLabel,'') <>''  AND COALESCE(forestCluster.ETSCaseId_max,'') <> ''

		-- Update build number
		IF EXISTS (SELECT * FROM ForestClusterBuild)
			UPDATE ForestClusterBuild 
			SET BuildNumber = @BuildNumber,
				LastExtractionDate = GETDATE() 
		ELSE
			INSERT INTO ForestClusterBuild (BuildNumber) Values (@BuildNumber);
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH