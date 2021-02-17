CREATE VIEW [dbo].[vwMigrationAlert]
	AS 

  SELECT MigrationRunId, NTBSNotificationId, STRING_AGG ( AlertType, ', ')  AS AlertTypes   
	FROM MigrationAlert
 	GROUP BY MigrationRunId, NTBSNotificationId
