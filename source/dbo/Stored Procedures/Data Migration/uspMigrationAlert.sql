CREATE PROCEDURE [dbo].[uspMigrationAlert]
@MigrationRunId int	 
AS

INSERT INTO MigrationAlert (MigrationRunId,NTBSNotificationId,AlertType)
SELECT mrr.MigrationRunId, mrr.NTBSNotificationId, a.AlertType
  FROM [MigrationRunResults] mrr
  inner join [$(NTBS)].[dbo].[Alert] a on a.NotificationId = mrr.NTBSNotificationId
  where AlertStatus = 'Open' and mrr.MigrationRunId = @MigrationRunId

