CREATE PROCEDURE [dbo].[uspUpdatePeriodicLegacyTOMFields]
	@TimePeriod int = 0
AS
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
		le.NtbsId														AS 'NotificationId',
		@TimePeriod														AS 'TimePeriod',
		''																AS 'TOMTreatmentInterruptedReason',
		''																AS 'TOMTreatmentChangedReason',
		CASE	
			WHEN po.OutcomeValue IN ('Completed', 'Cured') THEN 'Yes'
			WHEN po.OutcomeValue = 'No outcome recorded' THEN ''
			ELSE 'No'
		END																AS 'TOMCompleteCourse',
		CASE
			WHEN po.OutcomeValue = 'Lost to follow-up' THEN 'The patient was lost to follow-up before the end of treatment'
			WHEN po.OutcomeValue = 'Died' THEN 'Patient died before or while on treatment'
			WHEN po.TreatmentOutcomeSubType = 'StillOnTreatment' THEN CONCAT('Planned course of treatment exceeds ', @TimePeriod * 12, ' months')
			WHEN po.OutcomeValue NOT IN ('Completed', 'Cured', 'No outcome recorded') THEN po.OutcomeValue

			ELSE ''
		END																AS 'TOMIncompleteReason',
		COALESCE(FORMAT(po.EventDate, 'dd/MM/yyyy'), '')				AS 'TOMSubmittedDate',
		CASE
			WHEN po.OutcomeValue = 'Lost to follow-up' AND po.TreatmentOutcomeSubType = 'PatientLeftUk' THEN 'Patient left the UK'
			WHEN po.OutcomeValue = 'Lost to follow-up' AND po.TreatmentOutcomeSubType != 'PatientLeftUk' THEN 'Other'
			ELSE ''
		END																AS 'TOMFollowUpResult',

		CASE
			WHEN po.OutcomeValue = 'Died' AND le.PostMortemDiagnosis = 'No' THEN FORMAT(po.EventDate, 'dd/MM/yyyy')
		END																AS 'TOMDeathDate',
		CASE
			WHEN po.OutcomeValue = 'Died' AND le.PostMortemDiagnosis = 'No' THEN dl.DeathDescription
			ELSE ''
		END																AS 'TOMDeathRelationship',
		CASE
			WHEN po.OutcomeValue IN ('Completed', 'Cured') THEN FORMAT(po.EventDate, 'dd/MM/yyyy')
		END																AS 'TOMEndOfTreatmentDate',
		CASE
			WHEN po.OutcomeValue IN ('Completed', 'Cured') AND po.TreatmentOutcomeSubType = 'StandardTherapy' 
				THEN 'Standard recommended treatment of 6 months (2 months IRPE and 4 of IR)'
			WHEN po.OutcomeValue IN ('Completed', 'Cured') AND po.TreatmentOutcomeSubType != 'StandardTherapy'
				THEN 'Other'
			ELSE ''
		END																AS 'TOMTreatmentRegimen',
		''																AS 'TOMNonTuberculousMycobacteria',
		''																AS 'TOMConversion',
		COALESCE(po.Note, '')											AS 'TOMComment',
		CASE
			WHEN po.TreatmentOutcomeSubType = 'StillOnTreatment' THEN 'Other'
			ELSE ''
		END																AS 'TOMReasonExceeds',
		CASE
			WHEN po.OutcomeValue = 'No outcome recorded' THEN 'No'
			WHEN po.OutcomeValue IS NULL THEN 'NA'
			ELSE 'Yes'
		END																AS 'TOMReported'
	FROM
		[dbo].[LegacyExtract] le
		CROSS APPLY ufnGetPeriodicOutcome(@TimePeriod, le.NtbsId) po
		LEFT OUTER JOIN [dbo].[DeathLookup] dl ON dl.DeathCode = po.TreatmentOutcomeSubType
	WHERE le.SourceSystem = 'NTBS'
RETURN 0
