/*this will parse and populate the MigrationResults table with information about a migration into NTBS which is assumed to 
have just completed */

CREATE PROCEDURE [dbo].[uspGenerateMigrationResultsData]
	
AS
	--fetch all the data from Hangfire.Set with a job code later than the last job code already processed

	--this will be assumed to all relate to the first record in MigrationRun where the ImportedDate is NULL
BEGIN TRY
		
	BEGIN TRANSACTION

	TRUNCATE TABLE [dbo].[MigrationRawData];

	DECLARE @MigrationRunID INT = NULL
	SET @MigrationRunID = (SELECT TOP(1) MigrationRunId FROM MigrationRun WHERE ImportedDate IS NULL)

	DECLARE @StartJobNumber INT = NULL
	DECLARE @PreviousJobNumber INT = NULL
	--the first job in Hangfire with text like NOTIFICATION IMPORT, after the last job of the previous migration run
	SET @PreviousJobNumber = (SELECT TOP (1) HangfireEndJob FROM MigrationRun WHERE ImportedDate IS NOT NULL ORDER BY MigrationRunId DESC)
	SET @StartJobNumber = 
		(
		SELECT MIN(CONVERT(INT, SUBSTRING([Key], 20, 6)))
		FROM [$(NTBS)].[HangFire].[Set]
		WHERE [Value] LIKE '%NOTIFICATION IMPORT%'
		AND CONVERT(INT, SUBSTRING([Key], 20, 6)) > @PreviousJobNumber
		)

	DECLARE @EndJobNumber INT = NULL
	SET @EndJobNumber = 
		(
		SELECT MAX(CONVERT(INT, SUBSTRING([Key], 20, 6)))
		FROM [$(NTBS)].[HangFire].[Set]
		WHERE [Value] LIKE '%NOTIFICATION IMPORT%'
		)

	UPDATE [dbo].[MigrationRun] SET	
		HangfireStartJob = @StartJobNumber,
		HangfireEndJob = @EndJobNumber
	WHERE
		MigrationRunId = @MigrationRunID


	INSERT INTO [dbo].[MigrationRawData](MigrationRunId, JobNumber, JobCode, Score, ExpireAt, RowDetails)
	SELECT @MigrationRunID, Q1.JobNumber, Q1.JobCode, Q1.Score, Q1.ExpireAt, Q1.RowDetails
	FROM
	(SELECT CONVERT(INT, SUBSTRING([Key], 20, 6)) AS JobNumber
		  , [Key] AS JobCode
		  ,[Score]
		  ,[Value] AS RowDetails
		  ,[ExpireAt]
	  FROM [$(NTBS)].[HangFire].[Set]) AS Q1
	WHERE Q1.JobNumber BETWEEN @StartJobNumber AND @EndJobNumber


	--now remove the rows we don't care about
    DELETE FROM [dbo].[MigrationRawData] 
	WHERE
	[RowDetailS] LIKE '%Validating notification with Id=%'
	OR [RowDetails]  LIKE '%Request to import by Id%'
	OR [RowDetails] LIKE '%valid notifications%'
	OR [RowDetails] LIKE '%No validation errors found%'
	OR [RowDetails] LIKE '%Finished importing%'
	OR [RowDetails] LIKE '%Imported notifications have following Ids:%'
	OR [RowDetails] LIKE '%notifications found to import for%'
	OR [RowDetails] LIKE '%"r":true%'
	OR [RowDetails] LIKE '%This might cause the notifications to keep showing up as legacy in search results until corrected%'


	--and remove the content that we don't want.
	--TODO should make it more efficient to remove the #ff type data but this will do for now
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = RIGHT([RowDetails], LEN([RowDetails])-CHARINDEX('-', [RowDetails], CHARINDEX('-', [RowDetails])+1)-1)
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = REPLACE([RowDetails], '"}', '')
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = REPLACE([RowDetails], '","c":"#00ff00', '')
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = REPLACE([RowDetails], '","c":"#ffff00', '')
	UPDATE [dbo].[MigrationRawData] SET [RowDetails] = REPLACE([RowDetails], '","c":"#ff0000', '')

	--now we need to parse out the rows that say 'Fetching data for legacy notifications' as this will give us the list of notification Ids
	--and insert these rows into [MigrationRunResults]

	
	INSERT INTO [dbo].[MigrationRunResults](MigrationRunId, MigrationNotificationId)
	(
	SELECT DISTINCT @MigrationRunID, TRIM(value) NotificationId
	FROM 
		(SELECT SUBSTRING(RowDetails, 40, 40) AS NotificationIds FROM MigrationRawData
		WHERE RowDetails like 'Fetching data for legacy notifications%' ) AS Q1
    CROSS APPLY STRING_SPLIT(NotificationIds, ',')
	)



	
	--and then delete those rows from MigrationRawData
	DELETE FROM [dbo].[MigrationRawData] 
	WHERE [RowDetails] LIKE 'Fetching data for legacy notifications%'

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

	 --now we can populate data for each notification which the application attempted to migrate

	 --we can use MergedNotifications as the source of info about the legacy Notification, as we have used the primary notification ID to create each row in MigrationRunResults
	 --unfortunately, not all the error data will be quite so straight forward.

	 UPDATE mrr
		SET LegacyETSId = mn.EtsId,
		LegacyRegion = p.PHEC_Name,
		LegacyLtbrNo = mn.LtbrId,
		LegacyHospitalId = mn.OldHospitalId,
		LegacyHospitalName = mn.OldHospitalName,
		NotificationDate = mn.NotificationDate,
		SourceSystem = mn.PrimarySource,
		GroupId = mn.GroupId,
		NTBSNotificationId = ntbs.NotificationId,
		NTBSHospitalName = hos.[Name],
		TBServiceName = tbs.[Name],
		NTBSRegion = region.[Name],
		NTBSTreatmentOutcome = COALESCE(po3.OutcomeValue, po2.OutcomeValue, po1.OutcomeValue),
		EtsTreatmentOutcome = 
		--calculate the ETS Treatment outcome from scratch as the reusable notification table may not contain the 
		--ETS record
			COALESCE(
				CASE
					WHEN tr36.Id IS NULL THEN NULL
					ELSE dbo.ufnGetTreatmentOutcome(
							'36',
							tr36.AnswerToCompleteQuestion,
							tr36.AnswerToIncompleteReason1,
							tr36.AnswerToIncompleteReason2
						 )
				END,
				CASE
					WHEN tr24.Id IS NULL THEN NULL
					ELSE dbo.ufnGetTreatmentOutcome(
							'24',
							tr24.AnswerToCompleteQuestion,
							tr24.AnswerToIncompleteReason1,
							tr24.AnswerToIncompleteReason2
						 )
				END,
				CASE
					WHEN te.PostMortemDiagnosis = 1 THEN 'Died'
					ELSE dbo.ufnGetTreatmentOutcome(
							'12',
							tr12.AnswerToCompleteQuestion,
							tr12.AnswerToIncompleteReason1,
							tr12.AnswerToIncompleteReason2
						 )
				END)
	FROM  [dbo].[MigrationRunResults] mrr
	INNER JOIN [$(migration)].[dbo].[MergedNotifications] mn ON mn.PrimaryNotificationId = mrr.MigrationNotificationId
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON CONVERT(NVARCHAR(200), tbh.HospitalID) = mn.OldHospitalId
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
	LEFT OUTER JOIN  [$(NTBS)].[dbo].[Notification] ntbs ON ntbs.ETSID = mn.EtsId
	LEFT OUTER JOIN  [$(NTBS)].[dbo].[HospitalDetails] h ON h.NotificationId = ntbs.NotificationId
	LEFT OUTER JOIN  [$(NTBS)].[ReferenceData].[Hospital] hos ON hos.HospitalId = h.HospitalId
	LEFT OUTER JOIN  [$(NTBS)].[ReferenceData].[TbService] tbs ON tbs.Code = hos.TBServiceCode
	LEFT OUTER JOIN  [$(NTBS)].[ReferenceData].[PHEC] region ON region.Code = tbs.PHECCode
	LEFT OUTER JOIN  [$(ETS)].[dbo].[Notification] n ON n.LegacyId = mrr.LegacyETSId
	LEFT OUTER JOIN  [$(ETS)].[dbo].[TuberculosisEpisode] te ON te.Id = n.TuberculosisEpisodeId
	LEFT OUTER JOIN  [$(ETS)].[dbo].[TreatmentOutcome] tr12 ON tr12.Id = n.TreatmentOutcomeId
	LEFT OUTER JOIN  [$(ETS)].[dbo].TreatmentOutcomeTwentyFourMonth tr24 ON tr24.Id = n.TreatmentOutcomeTwentyFourMonthId
	LEFT OUTER JOIN  [$(ETS)].[dbo].TreatmentOutcome36Month tr36 ON tr36.Id = n.TreatmentOutcome36MonthId
	CROSS APPLY [dbo].[ufnGetPeriodicOutcome](1, mrr.NtbsNotificationId) po1
	OUTER APPLY [dbo].[ufnGetPeriodicOutcome](2, mrr.NtbsNotificationId) po2
	OUTER APPLY [dbo].[ufnGetPeriodicOutcome](3, mrr.NtbsNotificationId) po3

	WHERE mrr.MigrationRunId = @MigrationRunID


	--perform an update to determine whether or not proxy dates were used for test results

	UPDATE mrr
		SET ProxyTestDateUsed = Q1.ProxyDateUsed
	FROM  [dbo].[MigrationRunResults] mrr
	INNER JOIN 
	(SELECT MigrationNotificationId, CASE WHEN cd.[Notes] LIKE '%Proxy date used for one or more manually-entered test results%' THEN 'Yes' ELSE 'No' END AS ProxyDateUsed
		FROM  [dbo].[MigrationRunResults] mrr
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Notification] ntbs ON ntbs.ETSID = mrr.MigrationNotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ClinicalDetails] cd ON cd.NotificationId = ntbs.NotificationId
		WHERE mrr.MigrationRunId = @MigrationRunID) AS Q1 ON Q1.MigrationNotificationId = mrr.MigrationNotificationId




	--now match to errors logged in MigrationRawData.  There may be multiple rows per notification so these are grouped together
	--unfortunately some are logged using the LTBR ID even if ETS is primary


	UPDATE mrr
		SET mrr.MigrationResult = Q2.Result,
		mrr.MigrationNotes = Q2.Reason
	FROM  [dbo].[MigrationRunResults] mrr
		INNER JOIN 
			(SELECT 
			NotificationId, 
			CASE 
				WHEN MIN(Score) = 1 THEN 'Error'
				ELSE 'Data Loss'
			END AS Result,  
			STRING_AGG(Reason, ', ') AS Reason FROM
					(SELECT DISTINCT 
						NotificationId, 
						CASE 
							WHEN Category = 'Error' THEN 1 
							ELSE 2 
						END AS Score, 
						--Category, 
						Reason FROM MigrationRawData) AS Q1 
			GROUP BY NotificationId) AS Q2
		ON Q2.NotificationId = mrr.LegacyETSId
	WHERE mrr.MigrationRunId = @MigrationRunID
		--repeat this but matching on LTBR Id

	UPDATE mrr
		SET mrr.MigrationResult = Q2.Result,
		mrr.MigrationNotes = Q2.Reason
	FROM  [dbo].[MigrationRunResults] mrr
		INNER JOIN 
			(SELECT 
			NotificationId, 
			CASE 
				WHEN MIN(Score) = 1 THEN 'Error'
				ELSE 'Data Loss'
			END AS Result,  
			STRING_AGG(Reason, ', ') AS Reason FROM
					(SELECT DISTINCT 
						NotificationId, 
						CASE 
							WHEN Category = 'Error' THEN 1 
							ELSE 2 
						END AS Score, 
						--Category, 
						Reason FROM MigrationRawData) AS Q1 
			GROUP BY NotificationId) AS Q2
		ON Q2.NotificationId = mrr.LegacyLtbrNo
	WHERE mrr.MigrationRunId = @MigrationRunID

	--then do an update for success cases

	UPDATE [dbo].[MigrationRunResults] SET MigrationResult = 'Success'
		WHERE MigrationResult IS NULL
		AND NTBSNotificationId IS NOT NULL
		AND MigrationRunId = @MigrationRunID;
		
	--and finally there may be a few rows where the record did not migrate because of an error on another record in its group
	--so it has no error records itself

	WITH GroupErrors AS
	(SELECT DISTINCT mrd.NotificationId, mn.GroupId, CONCAT('Error on linked notification ', mrd.NotificationId) AS Reason
	FROM [dbo].[MigrationRawData] mrd
		INNER JOIN [$(migration)].[dbo].[MergedNotifications] mn ON mn.PrimaryNotificationId = mrd.NotificationId
	WHERE mrd.Category = 'Error' AND mn.GroupId IS NOT NULL),
	GroupReason AS
	(--now we need to get just one record per group
	SELECT GroupId, MIN(Reason) AS 'Reason'
	FROM GroupErrors
	GROUP BY GroupId)
	
	UPDATE mrr
		SET mrr.MigrationResult = 'Error',
		mrr.MigrationNotes = gr.Reason
	FROM  [dbo].[MigrationRunResults] mrr
		INNER JOIN 
			GroupReason gr ON gr.GroupId = mrr.GroupId
		WHERE mrr.MigrationResult IS NULL
		AND mrr.MigrationRunId = @MigrationRunID


	--now we can mark the migration runs as imported
	UPDATE [dbo].[MigrationRun]
		SET ImportedDate = GETUTCDATE(),
		EtsDate = (SELECT CONVERT(DATE, MAX(NotificationDate)) AS EtsDate FROM [$(ETS)].[dbo].[Notification]),
		LtbrDate = (SELECT CONVERT(DATE, MAX(dp_NotifiedDate)) AS LtbrDate FROM [$(LTBR)].[dbo].[dbt_DiseasePeriod]),
		LabbaseDate = (SELECT CONVERT(DATE, MAX(AuditCreate)) AS LabbaseDate FROM [$(Labbase2)].[dbo].[Anonymised])
		WHERE MigrationRunId = @MigrationRunID

	COMMIT
END TRY
	
BEGIN CATCH
		-- A "Generate" proc has errored
		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  

		-- Show error on screen
		EXEC dbo.uspHandleException
END CATCH

RETURN 0
