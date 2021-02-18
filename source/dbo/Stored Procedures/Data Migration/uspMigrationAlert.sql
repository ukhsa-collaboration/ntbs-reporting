CREATE PROCEDURE [dbo].[uspMigrationAlert]
@MigrationRunId int	 
AS

INSERT INTO MigrationAlert (MigrationRunId,MigrationNotificationId,AlertType)
SELECT mrr.MigrationRunId, mrr.MigrationNotificationId, a.AlertType
  FROM [MigrationRunResults] mrr
  inner join [$(NTBS)].[dbo].[Alert] a on a.NotificationId = mrr.NTBSNotificationId
  where AlertStatus = 'Open' and mrr.MigrationRunId = @MigrationRunId

