CREATE VIEW [dbo].[vwMigrationAlert]
	AS 

  SELECT MigrationRunId, MigrationNotificationId, STRING_AGG ( AlertType, ', ')  AS AlertTypes   
	FROM MigrationAlert
 	GROUP BY MigrationRunId, MigrationNotificationId
