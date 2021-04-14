CREATE PROCEDURE [dbo].[uspGenerateReportingLegacyPeriodicTOMFields]
	@TimePeriod int = 0
AS
BEGIN TRY
	INSERT INTO [dbo].[LegacyPeriodicOutcome]
		([NotificationId], 
		[TimePeriod], 
		[TOMTreatmentInterruptedReason],
		[TOMTreatmentChangedReason],
		[TOMCompleteCourse],
		[TOMIncompleteReason],
		[TOMSubmittedDate],
		[TOMFollowUpResult],
		[TOMDeathDate],
		[TOMDeathRelationship],
		[TOMEndOfTreatmentDate],
		[TOMTreatmentRegimen],
		[TOMNonTuberculousMycobacteria],
		[TOMConversion],
		[TOMComment],
		[TOMReasonExceeds],
		[TOMReported])

	SELECT
		le.NotificationId												AS NotificationId,
		@TimePeriod														AS TimePeriod,
		NULL															AS TOMTreatmentInterruptedReason,
		NULL															AS TOMTreatmentChangedReason,
		CASE	
			WHEN po.OutcomeValue IN ('Completed', 'Cured') THEN 'Yes'
			WHEN po.OutcomeValue = 'No outcome recorded' THEN NULL
			ELSE 'No'
		END																AS TOMCompleteCourse,
		CASE
			WHEN po.OutcomeValue = 'Lost to follow-up' THEN 'The patient was lost to follow-up before the end of treatment'
			WHEN po.OutcomeValue = 'Died' THEN 'Patient died before or while on treatment'
			WHEN po.TreatmentOutcomeSubType = 'StillOnTreatment' THEN CONCAT('Planned course of treatment exceeds ', @TimePeriod * 12, ' months')
			WHEN po.OutcomeValue NOT IN ('Completed', 'Cured', 'No outcome recorded') THEN po.OutcomeValue
			ELSE NULL
		END																AS TOMIncompleteReason,
		FORMAT(po.EventDate, 'dd/MM/yyyy')								AS TOMSubmittedDate,
		CASE
			WHEN po.OutcomeValue = 'Lost to follow-up' AND po.TreatmentOutcomeSubType = 'PatientLeftUk' THEN 'Patient left the UK'
			WHEN po.OutcomeValue = 'Lost to follow-up' AND po.TreatmentOutcomeSubType != 'PatientLeftUk' THEN 'Other'
			ELSE NULL
		END																AS TOMFollowUpResult,

		CASE
			WHEN po.OutcomeValue = 'Died' AND cd.PostMortemDiagnosis = 'No' THEN FORMAT(po.EventDate, 'dd/MM/yyyy')
		END																AS TOMDeathDate,
		CASE
			WHEN po.OutcomeValue = 'Died' AND cd.PostMortemDiagnosis = 'No' THEN dl.DeathDescription
			ELSE NULL
		END																AS TOMDeathRelationship,
		CASE
			WHEN po.OutcomeValue IN ('Completed', 'Cured') THEN FORMAT(po.EventDate, 'dd/MM/yyyy')
		END																AS TOMEndOfTreatmentDate,
		CASE
			WHEN po.OutcomeValue IN ('Completed', 'Cured') AND po.TreatmentOutcomeSubType = 'StandardTherapy' 
				THEN 'Standard recommended treatment of 6 months (2 months IRPE and 4 of IR)'
			WHEN po.OutcomeValue IN ('Completed', 'Cured') AND po.TreatmentOutcomeSubType != 'StandardTherapy'
				THEN 'Other'
			ELSE NULL
		END																AS TOMTreatmentRegimen,
		NULL															AS TOMNonTuberculousMycobacteria,
		NULL															AS TOMConversion,
		po.Note															AS TOMComment,
		CASE
			WHEN po.TreatmentOutcomeSubType = 'StillOnTreatment' THEN 'Other'
			ELSE NULL
		END																AS TOMReasonExceeds,
		CASE
			WHEN po.OutcomeValue = 'No outcome recorded' THEN 'No'
			WHEN po.OutcomeValue IS NULL THEN 'NA'
			ELSE 'Yes'
		END																AS TOMReported
	FROM
		[dbo].[Record_LegacyExtract] le
			INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = le.NotificationId
			INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = rr.NotificationId
			CROSS APPLY ufnGetPeriodicOutcome(@TimePeriod, le.NotificationId) po
			LEFT OUTER JOIN [dbo].[DeathLookup] dl ON dl.DeathCode = po.TreatmentOutcomeSubType
	WHERE rr.SourceSystem = 'NTBS'
END TRY
BEGIN CATCH
	THROW
END CATCH
