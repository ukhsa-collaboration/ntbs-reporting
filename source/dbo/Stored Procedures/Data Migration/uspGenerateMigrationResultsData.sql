CREATE PROCEDURE [dbo].[uspGenerateMigrationResultsData]
	
AS
	--this will need to work for every migration run which doesn't have an imported date, and use the date to set the migration run

	--get the Hangfire data

	DECLARE @EarliestImportDate DATE = NULL

	--we want to import data where the 'Expire at' is 14 days later than the migration run 
	SELECT @EarliestImportDate = DATEADD(DAY, 14, MIN(MigrationRunDate)) FROM [dbo].[MigrationRun] WHERE ImportedDate IS NULL

	TRUNCATE TABLE [dbo].[MigrationRawData];

	WITH HangfireData AS
	(SELECT LEFT(h.[Value], 30) AS 'JobNumber', Q1.JobCode, Q1.Score, Q1.ExpireAt, Q1.[Value] as 'RowDetails' 
	FROM [$(NTBS)].[HangFire].[Hash] h 
	INNER JOIN
		(SELECT RIGHT(s.[Key], LEN(s.[Key])-8) AS [JobCode], *
		FROM [$(NTBS)].[HangFire].[Set] s
		WHERE s.[Value]  LIKE '%NOTIFICATION IMPORT%' and ExpireAt > @EarliestImportDate) AS Q1 on CONCAT('console:refs:', Q1.JobCode) = h.[Key]),
	MigrationDates AS
	(SELECT MigrationRunId, DATEADD(DAY, 14, MigrationRunDate) AS ExpiryDate
	 FROM [dbo].[MigrationRun] WHERE ImportedDate IS NULL)

	INSERT INTO [dbo].[MigrationRawData](MigrationRunId, JobNumber, JobCode, Score, ExpireAt, RowDetails)
	SELECT MigrationRunId, JobNumber, JobCode, Score, ExpireAt, RowDetails
	FROM HangfireData h
		LEFT OUTER JOIN MigrationDates m ON m.ExpiryDate = CONVERT(DATE, h.ExpireAt)
	WHERE MigrationRunId IS NOT NULL

	--now remove the rows we don't care about
    DELETE FROM [dbo].[MigrationRawData] WHERE
	[RowDetails]  like '%Fetching data for legacy notifications%'
	OR [RowDetails]  LIKE '%Request to import by Id%'
	OR [RowDetails] LIKE '%valid notifications%'
	OR [RowDetails] LIKE '%No validation errors found%'
	OR [RowDetails] LIKE '%Finished importing%'
	OR [RowDetails] LIKE '%Imported notifications have following Ids:%'
	OR [RowDetails] LIKE '%notifications found to import for%'
	OR [RowDetails] LIKE '%Validating notification with Id%'



	--and remove the content that we don't want.
	--TODO should make it more efficient to remove the #ff type data but this will do for now
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = RIGHT([RowDetails], LEN([RowDetails])-CHARINDEX('-', [RowDetails], CHARINDEX('-', [RowDetails])+1)-1)
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = REPLACE([RowDetails], '"}', '')
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = REPLACE([RowDetails], '","c":"#00ff00', '')
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = REPLACE([RowDetails], '","c":"#ffff00', '')
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = REPLACE([RowDetails], '","c":"#ff0000', '')


	--now we can try to parse the Notification Id out on the rows that have them
	--the substrings here need to be update to cater for shorter IDs and LTBR Ids which could be longer

	UPDATE [dbo].[MigrationRawData] SET [NotificationId] = 
		CASE 
			WHEN RowDetails LIKE 'Notification [0-9]%' THEN [dbo].[ufnGetMigrationNotificationId] (SUBSTRING(RowDetails, CHARINDEX(' ', RowDetails), 10))
			WHEN RowDetails LIKE '%validation errors found for notification with Id=%' OR RowDetails LIKE 'Notification with Id=%' 
				THEN [dbo].[ufnGetMigrationNotificationId] (SUBSTRING(RowDetails, CHARINDEX('=', RowDetails), 10))
		END
	WHERE NotificationId IS NULL


	UPDATE [dbo].[MigrationRawData] SET [Category] = 
		CASE 
			WHEN RowDetails LIKE '%will be imported without%' THEN 'Data Loss'
			ELSE 'Error'
		END
	WHERE Category IS NULL

	--now we have to 'fill down' to get the notification Ids for the error records which don't have them

	UPDATE [dbo].[MigrationRawData] SET [ChangeIndicator] = 
		CASE WHEN NotificationId IS NULL THEN 0 ELSE 1 END
	WHERE ChangeIndicator IS NULL;

	--now fill down a row group
	
	WITH RowGroupData AS
	(SELECT JobNumber, Score, SUM(ChangeIndicator) OVER (ORDER BY JobNumber, Score) AS RowGroup
		FROM [dbo].[MigrationRawData])

	UPDATE mrd SET [RowGroup] = 
		rgd.RowGroup 
		FROM RowGroupData rgd
		INNER JOIN [dbo].[MigrationRawData] mrd ON mrd.JobNumber = rgd.JobNumber AND mrd.Score = rgd.Score;

	--so that now we can fill down the missing notification Ids

	WITH NotifcationIdForRowGroup AS
	(SELECT DISTINCT RowGroup, 
		CASE WHEN NotificationId IS NOT NULL THEN NotificationId
		ELSE FIRST_VALUE(NotificationId) OVER (PARTITION BY RowGroup ORDER BY JobNumber, Score)
		END AS 'NotificationId'
	FROM [dbo].[MigrationRawData])

	UPDATE mrd SET NotificationId = 
		nrg.NotificationId
		FROM NotifcationIdForRowGroup nrg INNER JOIN [dbo].[MigrationRawData] mrd on mrd.RowGroup = nrg.RowGroup
	WHERE mrd.NotificationId IS NULL


	--now we can delete the rows where it says 'Terminating' and 'validation errors found'
	--as we have copied the NotificationId from them to where we need it

	 DELETE FROM [dbo].[MigrationRawData] 
	 WHERE
	 [RowDetails]  like '%validation errors found for notification with%'
	 OR [RowDetails]  LIKE '%Terminating importing notifications for%'

	 --and remove content of ChangeIndicator and RowGroup as neither will now make sense

	 UPDATE [dbo].[MigrationRawData] SET ChangeIndicator = NULL, RowGroup = NULL

	 UPDATE [dbo].[MigrationRawData] SET Reason =
		CASE
			WHEN CHARINDEX([NotificationId], RowDetails) = 0 THEN RowDetails
			ELSE [dbo].[ufnGetMigrationDataLossReason] (SUBSTRING(RowDetails, CHARINDEX([NotificationId], RowDetails)+LEN([NotificationId])+1, 40))
		END
	 WHERE Reason IS NULL

	 SELECT DISTINCT MigrationRunId, JobNumber, NotificationId, Category, Reason FROM [dbo].[MigrationRawData]

RETURN 0
