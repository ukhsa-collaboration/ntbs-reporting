CREATE VIEW [dbo].[vwHangfireJobs]
	AS
	SELECT 
		SUBSTRING(Q1.InvocationData, 25, EndOfString-25) AS JobName, 
		Q1.StateName, 
		Q1.CreatedAt 
	FROM
		(SELECT StateName, CreatedAt, CHARINDEX(',',InvocationData, 1) AS EndOfString, InvocationData
		FROM [$(NTBS)].[HangFire].[Job]
		WHERE InvocationData LIKE '%ntbs_service.Jobs.%'
		) AS Q1

  --we want the text after {"t":"ntbs_service.Jobs.UserSyncJob, ntbs-service","m":"Run","p":["Hangfire.IJobCancellationToken, Hangfire.Core"]}
  --and before the first comma
