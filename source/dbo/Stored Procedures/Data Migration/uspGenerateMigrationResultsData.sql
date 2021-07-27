/*this will parse and populate the MigrationResults table with information about a migration into NTBS which is assumed to 
have just completed */

CREATE PROCEDURE [dbo].[uspGenerateMigrationResultsData]
	
AS
	--fetch all the data from Hangfire.Set with a job code later than the last job code already processed

	--this will be assumed to all relate to the first record in MigrationRun where the ImportedDate is NULL
BEGIN TRY
		
	BEGIN TRANSACTION

	DECLARE @MigrationRunID INT = NULL

	--first bring in the summary info about the last migration run found that has not yet been imported
	SET @MigrationRunID = (SELECT MAX(lmr.LegacyImportMigrationRunId) AS MigrationRunId
	FROM
	[$(NTBS)].[dbo].[LegacyImportMigrationRun] lmr 
	WHERE lmr.LegacyImportMigrationRunId > (SELECT COALESCE(MAX(MigrationRunId), 0) FROM [dbo].[MigrationRun] WHERE ImportedDate IS NOT NULL))

	
	INSERT INTO [dbo].[MigrationRun](MigrationRunId, MigrationRunDate, MigrationRunName, AppVersion)
		SELECT lmr.LegacyImportMigrationRunId, lmr.StartTime, lmr.[Description], lmr.AppRelease
		FROM [$(NTBS)].[dbo].[LegacyImportMigrationRun] lmr
		WHERE lmr.LegacyImportMigrationRunId = @MigrationRunID

	
	--then add a row into the MigrationRunResults table for every record on which the migration was attempted

	INSERT INTO [dbo].[MigrationRunResults](
		MigrationRunId
		,MigrationNotificationId
		,NTBSNotificationId
		,LegacyETSId
		,LegacyRegion
		,LegacyLtbrNo
		,LegacyHospitalId
		,LegacyHospitalName
		,NotificationDate
		,SourceSystem
		,GroupId
		,NTBSHospitalName
		,NTBSCaseManagerUsername
		,TBServiceName
		,NTBSRegion
		)
		(SELECT 
			lino.LegacyImportMigrationRunId
			,lino.OldNotificationId
			,CASE lino.NtbsId
				WHEN 0 THEN NULL
				ELSE lino.NtbsId
				END
				AS NtbsNotificationId
			,mn.EtsId
			--when the legacy record is mastered in LTBR, the lookup from hospital ID to region won't succeed
			,CASE 
				WHEN
					mn.PrimarySource = 'LTBR' AND tbsp.TB_Service_Code IS NULL THEN 'London'
				ELSE
					p.PHEC_Name
				END AS LegacyRegion
			,mn.LtbrId
			,mn.OldHospitalId
			,mn.OldHospitalName
			,mn.NotificationDate
			,mn.PrimarySource
			,mn.GroupId
			,hos.[Name]
			,u.Username
			,tbs.[Name]
			,region.[Name]
		FROM [$(NTBS)].[dbo].[LegacyImportNotificationOutcome] lino
			INNER JOIN [$(migration)].[dbo].[MergedNotifications] mn ON mn.PrimaryNotificationId = lino.OldNotificationId
			LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON CONVERT(NVARCHAR(200), tbh.HospitalID) = mn.OldHospitalId
			LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
			LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
			LEFT OUTER JOIN  [$(NTBS)].[dbo].[Notification] ntbs ON ntbs.ETSID = mn.EtsId
			LEFT OUTER JOIN  [$(NTBS)].[dbo].[HospitalDetails] h ON h.NotificationId = ntbs.NotificationId
			LEFT OUTER JOIN  [$(NTBS)].[dbo].[User] u ON u.Id = h.CaseManagerId
			LEFT OUTER JOIN  [$(NTBS)].[ReferenceData].[Hospital] hos ON hos.HospitalId = h.HospitalId
			LEFT OUTER JOIN  [$(NTBS)].[ReferenceData].[TbService] tbs ON tbs.Code = hos.TBServiceCode
			LEFT OUTER JOIN  [$(NTBS)].[ReferenceData].[PHEC] region ON region.Code = tbs.PHECCode
		WHERE lino.LegacyImportMigrationRunId = @MigrationRunID
		)

	 

	--update the ETS outcome - this is easier to do once the ETS ID is in the results table
	 UPDATE mrr
		SET EtsTreatmentOutcome = 
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
	LEFT OUTER JOIN  [$(ETS)].[dbo].[Notification] n ON n.LegacyId = mrr.LegacyETSId
	LEFT OUTER JOIN  [$(ETS)].[dbo].[TuberculosisEpisode] te ON te.Id = n.TuberculosisEpisodeId
	LEFT OUTER JOIN  [$(ETS)].[dbo].[TreatmentOutcome] tr12 ON tr12.Id = n.TreatmentOutcomeId
	LEFT OUTER JOIN  [$(ETS)].[dbo].[TreatmentOutcomeTwentyFourMonth] tr24 ON tr24.Id = n.TreatmentOutcomeTwentyFourMonthId
	LEFT OUTER JOIN  [$(ETS)].[dbo].[TreatmentOutcome36Month] tr36 ON tr36.Id = n.TreatmentOutcome36MonthId
	WHERE mrr.MigrationRunId = @MigrationRunID;

	--then update the NTBS outcome, this is a bit more complicated due to the need to parse events happening on the same day

	WITH EventOrder AS
	(SELECT 'DiagnosisMade' AS EventName, 1 AS 'OrderBy'
		   UNION
		   SELECT 'TreatmentStart' AS EventName, 2 AS 'OrderBy'
		   UNION
		   SELECT 'TransferOut' AS EventName, 3 AS 'OrderBy'
		   UNION
		   SELECT 'TransferIn' AS EventName, 4 AS 'OrderBy'
		   UNION
		   SELECT 'TransferRestart' AS Eventname, 5 AS 'OrderBy'
		   UNION
		   SELECT 'TreatmentOutcome' AS EventName, 6 AS 'OrderBy'),
	AllEvents AS
	(SELECT DISTINCT 
		NotificationId,
		--get the most recent event for each notification
		COALESCE
		(FIRST_VALUE(ol.OutcomeDescription) 
			OVER (PARTITION BY NotificationId 
			ORDER BY EventDate DESC, OrderBy), 
		'No outcome recorded') AS 'OutcomeValue'
	FROM [$(NTBS)].[dbo].[TreatmentEvent] te 
		INNER JOIN [dbo].[MigrationRunResults] mrr ON mrr.NTBSNotificationId = te.NotificationId AND mrr.MigrationRunId = @MigrationRunID
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[TreatmentOutcome] tro ON tro.TreatmentOutcomeId = te.TreatmentOutcomeId
		LEFT OUTER JOIN [dbo].[OutcomeLookup] ol ON ol.OutcomeCode = tro.TreatmentOutcomeType
		LEFT OUTER JOIN EventOrder ev ON ev.EventName = tro.TreatmentOutcomeType)

	UPDATE mrr
		SET mrr.NTBSTreatmentOutcome = a.OutcomeValue
		FROM  [dbo].[MigrationRunResults] mrr
			INNER JOIN AllEvents a ON a.NotificationId = mrr.NTBSNotificationId
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
	WHERE mrr.MigrationRunId = @MigrationRunID;


	--now set the success (or otherwise) of the migration.  The result is one of:
		--Success, Data Loss, Error

	--error is easy to set but data loss is based on whether there are any warnings that indicate some data did not migrate in

	--I think if an actual group failed to migrate in, the error note is useful (as it explains why an otherwise valid notification
	--did not migrate in. Otherwise, the actual error notes are more usfeul

	WITH AggregatedResults AS
	(SELECT 
		  li.[LegacyImportMigrationRunId]
		  ,li.[OldNotificationId]
		  ,[SuccessfullyMigrated]
		  ,[Notes]
		  ,STRING_AGG(q1.[Message], ' ,') AS [Message]
	FROM 
		[$(NTBS)].[dbo].[LegacyImportNotificationOutcome] li
		LEFT OUTER JOIN 
			(SELECT DISTINCT
				LegacyImportMigrationRunId
				,OldNotificationId
				,(CASE 
					WHEN [Message] LIKE '%The notification will be imported without%' THEN LEFT([Message], CHARINDEX('.', [Message]) -1)
					ELSE [Message] 
				END) AS								[Message] 
	
			FROM [$(NTBS)].[dbo].[LegacyImportNotificationLogMessage]
			WHERE LegacyImportMigrationRunId = @MigrationRunID
			AND [Message] NOT LIKE 'has % validation errors'
			AND [Message] != 'User set as case manager for notification is not a case manager.') AS Q1 
				ON Q1.OldNotificationId = li.OldNotificationId AND Q1.LegacyImportMigrationRunId = li.LegacyImportMigrationRunId
	WHERE
		li.LegacyImportMigrationRunId = @MigrationRunID 
	GROUP BY 
      li.[LegacyImportMigrationRunId]
      ,li.[OldNotificationId]
      ,[SuccessfullyMigrated]
      ,[Notes])

	UPDATE mrr
		SET 
			mrr.MigrationNotes = COALESCE(ag.[Message], ag.[Notes])
			,mrr.MigrationResult = 
				CASE WHEN ag.SuccessfullyMigrated = 0 THEN 'Error'
				WHEN ag.SuccessfullyMigrated = 1 AND ag.[Message] IS NOT NULL THEN 'Data Loss'
				ELSE 'Success'
			END

	FROM  [dbo].[MigrationRunResults] mrr
		INNER JOIN AggregatedResults ag ON ag.LegacyImportMigrationRunId = mrr.MigrationRunId AND ag.OldNotificationId = mrr.MigrationNotificationId

		-----------------------------------------------------------------------------------------------------------------------------
   --Insert migration Alerts into table Migration Alert then 

   
   EXEC uspMigrationAlert @MigrationRunID

   UPDATE mrr
	SET MigrationAlerts = ma.AlertTypes
   FROM [dbo].[MigrationRunResults] mrr 
	INNER JOIN vwMigrationAlert ma on ma.MigrationRunId = mrr.MigrationRunId and ma.MigrationNotificationId = mrr.MigrationNotificationId
	WHERE ma.MigrationRunId = @MigrationRunID
   

   --now we can mark the migration runs as imported
	UPDATE [dbo].[MigrationRun]
		SET ImportedDate = GETUTCDATE(),
		EtsDate = (SELECT CONVERT(DATE, MAX(NotificationDate)) AS EtsDate FROM [$(ETS)].[dbo].[Notification]),
		LtbrDate = (SELECT CONVERT(DATE, MAX(dp_NotifiedDate)) AS LtbrDate FROM [$(LTBR)].[dbo].[dbt_DiseasePeriod]),
		LabbaseDate = (SELECT CONVERT(DATE, MAX(AuditCreate)) AS LabbaseDate FROM [$(Labbase2)].[dbo].[Anonymised])
		WHERE MigrationRunId = @MigrationRunID
-----------------------------------------------------------------------------------------------------------------------------

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
