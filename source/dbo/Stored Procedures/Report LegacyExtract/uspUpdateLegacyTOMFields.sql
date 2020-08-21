CREATE PROCEDURE [dbo].[uspUpdateLegacyTOMFields]
	
AS
	
	DELETE FROM [dbo].[LegacyPeriodicOutcome]

	EXEC [dbo].[uspUpdatePeriodicLegacyTOMFields] 1
	EXEC [dbo].[uspUpdatePeriodicLegacyTOMFields] 2
	EXEC [dbo].[uspUpdatePeriodicLegacyTOMFields] 3

	UPDATE [dbo].[LegacyExtract]

		SET
			[TOMTreatmentInterruptedReason] = COALESCE(po1.TOMTreatmentInterruptedReason, '')
			,[TOMTreatmentChangedReason] = COALESCE(po1.TOMTreatmentChangedReason, '')
			,[TOMCompleteCourse] = COALESCE(po1.TOMCompleteCourse, '')
			,[TOMIncompleteReason] = COALESCE(po1.TOMIncompleteReason, '')
			,[TOMSubmittedDate] = COALESCE(po1.TOMSubmittedDate, '')
			,[TOMFollowUpResult] = COALESCE(po1.TOMFollowUpResult, '')
			,[TOMDeathDate] = COALESCE(po1.TOMDeathDate, '')
			,[TOMDeathRelationship] = COALESCE(po1.TOMDeathRelationship, '')
			,[TOMEndOfTreatmentDate] = COALESCE(po1.TOMEndOfTreatmentDate, '')
			,[TOMTreatmentRegimen] = COALESCE(po1.TOMTreatmentRegimen, '')
			,[TOMNonTuberculousMycobacteria] = COALESCE(po1.TOMNonTuberculousMycobacteria, '')
			,[TOMConversion] = COALESCE(po1.TOMConversion, '')
			,[TOMComment] = COALESCE(po1.TOMComment, '')
			,[TOMReasonExceeds12mths] = COALESCE(po1.TOMReasonExceeds, '')
			,[TOMReported12mth] = COALESCE(po1.TOMReported, '')
			,[TOMTreatmentInterruptedReason24mth] = COALESCE(po2.TOMTreatmentInterruptedReason, '')
			,[TOMTreatmentChangedReason24mth] = COALESCE(po2.TOMTreatmentChangedReason, '')
			,[TOMCompleteCourse24mth] = COALESCE(po2.TOMCompleteCourse, '')
			,[TOMIncompleteReason24mth] = COALESCE(po2.TOMIncompleteReason, '')
			,[TOMSubmittedDate24mth] = COALESCE(po2.TOMSubmittedDate, '')
			,[TOMFollowUpResult24mth] = COALESCE(po2.TOMFollowUpResult, '')
			,[TOMDeathDate24mth] = COALESCE(po2.TOMDeathDate, '')
			,[TOMDeathRelationship24mth] = COALESCE(po2.TOMDeathRelationship, '')
			,[TOMEndOfTreatmentDate24mth] = COALESCE(po2.TOMEndOfTreatmentDate, '')
			,[TOMTreatmentRegimen24mth] = COALESCE(po2.TOMTreatmentRegimen, '')
			,[TOMNonTuberculousMycobacteria24mth] = COALESCE(po2.TOMNonTuberculousMycobacteria, '')
			,[TOMConversion24mth] = COALESCE(po2.TOMConversion, '')
			,[TOMComment24mth] = COALESCE(po2.TOMComment, '')
			,[TOMReasonExceeds24mths] = COALESCE(po2.TOMReasonExceeds, '')
			,[TOMReported24mth] = COALESCE(po2.TOMReported, 'NA')
			,[TOMTreatmentInterruptedReason36mth] = COALESCE(po3.TOMTreatmentInterruptedReason, '')
			,[TOMTreatmentChangedReason36mth] = COALESCE(po3.TOMTreatmentChangedReason, '')
			,[TOMCompleteCourse36mth] = COALESCE(po3.TOMCompleteCourse, '')
			,[TOMIncompleteReason36mth] = COALESCE(po3.TOMIncompleteReason, '')
			,[TOMSubmittedDate36mth] = COALESCE(po3.TOMSubmittedDate, '')
			,[TOMFollowUpResult36mth] = COALESCE(po3.TOMFollowUpResult, '')
			,[TOMDeathDate36mth] = COALESCE(po3.TOMDeathDate, '')
			,[TOMDeathRelationship36mth] = COALESCE(po3.TOMDeathRelationship, '')
			,[TOMEndOfTreatmentDate36mth] = COALESCE(po3.TOMEndOfTreatmentDate, '')
			,[TOMTreatmentRegimen36mth] = COALESCE(po3.TOMTreatmentRegimen, '')
			,[TOMNonTuberculousMycobacteria36mth] = COALESCE(po3.TOMNonTuberculousMycobacteria, '')
			,[TOMConversion36mth] = COALESCE(po3.TOMConversion, '')
			,[TOMComment36mth] = COALESCE(po3.TOMComment, '')
			,[TOMReported36mth] = COALESCE(po3.TOMReported, '')

	FROM
		[dbo].[LegacyExtract] le
			LEFT OUTER JOIN [dbo].[LegacyPeriodicOutcome] po1 ON po1.NotificationId = le.NtbsId AND po1.TimePeriod = 1
			LEFT OUTER JOIN [dbo].[LegacyPeriodicOutcome] po2 ON po2.NotificationId = le.NtbsId AND po2.TimePeriod = 2
			LEFT OUTER JOIN [dbo].[LegacyPeriodicOutcome] po3 ON po3.NotificationId = le.NtbsId AND po3.TimePeriod = 3

RETURN 0
