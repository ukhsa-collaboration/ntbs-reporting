CREATE PROCEDURE [dbo].[uspGenerateReportingLegacyTOMFields]
	
AS
BEGIN TRY	
	TRUNCATE TABLE [dbo].[LegacyPeriodicOutcome]

	EXEC [dbo].[uspGenerateReportingLegacyPeriodicTOMFields] 1
	EXEC [dbo].[uspGenerateReportingLegacyPeriodicTOMFields] 2
	EXEC [dbo].[uspGenerateReportingLegacyPeriodicTOMFields] 3

	UPDATE le

		SET
			[TOMTreatmentInterruptedReason] = po1.TOMTreatmentInterruptedReason
			,[TOMTreatmentChangedReason] = po1.TOMTreatmentChangedReason
			,[TOMCompleteCourse] = po1.TOMCompleteCourse
			,[TOMIncompleteReason] = po1.TOMIncompleteReason
			,[TOMSubmittedDate] = po1.TOMSubmittedDate
			,[TOMFollowUpResult] = po1.TOMFollowUpResult
			,[TOMDeathDate] = po1.TOMDeathDate
			,[TOMDeathRelationship] = po1.TOMDeathRelationship
			,[TOMEndOfTreatmentDate] = po1.TOMEndOfTreatmentDate
			,[TOMTreatmentRegimen] = po1.TOMTreatmentRegimen
			,[TOMNonTuberculousMycobacteria] = po1.TOMNonTuberculousMycobacteria
			,[TOMConversion] = po1.TOMConversion
			,[TOMComment] = po1.TOMComment
			,[TOMReasonExceeds12mths] = po1.TOMReasonExceeds
			,[TOMReported12mth] = po1.TOMReported
			,[TOMTreatmentInterruptedReason24mth] = po2.TOMTreatmentInterruptedReason
			,[TOMTreatmentChangedReason24mth] = po2.TOMTreatmentChangedReason
			,[TOMCompleteCourse24mth] = po2.TOMCompleteCourse
			,[TOMIncompleteReason24mth] = po2.TOMIncompleteReason
			,[TOMSubmittedDate24mth] = po2.TOMSubmittedDate
			,[TOMFollowUpResult24mth] = po2.TOMFollowUpResult
			,[TOMDeathDate24mth] = po2.TOMDeathDate
			,[TOMDeathRelationship24mth] = po2.TOMDeathRelationship
			,[TOMEndOfTreatmentDate24mth] = po2.TOMEndOfTreatmentDate
			,[TOMTreatmentRegimen24mth] = po2.TOMTreatmentRegimen
			,[TOMNonTuberculousMycobacteria24mth] = po2.TOMNonTuberculousMycobacteria
			,[TOMConversion24mth] = po2.TOMConversion
			,[TOMComment24mth] = po2.TOMComment
			,[TOMReasonExceeds24mths] = po2.TOMReasonExceeds
			,[TOMReported24mth] = COALESCE(po2.TOMReported, 'NA')
			,[TOMTreatmentInterruptedReason36mth] = po3.TOMTreatmentInterruptedReason
			,[TOMTreatmentChangedReason36mth] = po3.TOMTreatmentChangedReason
			,[TOMCompleteCourse36mth] = po3.TOMCompleteCourse
			,[TOMIncompleteReason36mth] = po3.TOMIncompleteReason
			,[TOMSubmittedDate36mth] = po3.TOMSubmittedDate
			,[TOMFollowUpResult36mth] = po3.TOMFollowUpResult
			,[TOMDeathDate36mth] = po3.TOMDeathDate
			,[TOMDeathRelationship36mth] = po3.TOMDeathRelationship
			,[TOMEndOfTreatmentDate36mth] = po3.TOMEndOfTreatmentDate
			,[TOMTreatmentRegimen36mth] = po3.TOMTreatmentRegimen
			,[TOMNonTuberculousMycobacteria36mth] = po3.TOMNonTuberculousMycobacteria
			,[TOMConversion36mth] = po3.TOMConversion
			,[TOMComment36mth] = po3.TOMComment
			,[TOMReported36mth] = po3.TOMReported

	FROM
		[dbo].[Record_LegacyExtract] le
			LEFT OUTER JOIN [dbo].[LegacyPeriodicOutcome] po1 ON po1.NotificationId = le.NotificationId AND po1.TimePeriod = 1
			LEFT OUTER JOIN [dbo].[LegacyPeriodicOutcome] po2 ON po2.NotificationId = le.NotificationId AND po2.TimePeriod = 2
			LEFT OUTER JOIN [dbo].[LegacyPeriodicOutcome] po3 ON po3.NotificationId = le.NotificationId AND po3.TimePeriod = 3
END TRY
BEGIN CATCH
	THROW
END CATCH
