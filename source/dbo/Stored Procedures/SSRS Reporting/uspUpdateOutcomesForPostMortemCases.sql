CREATE PROCEDURE [dbo].[uspUpdateOutcomesForPostMortemCases]
AS
BEGIN TRY
	UPDATE po SET OutcomeValue = ol.OutcomeDescription, DescriptiveOutcome = CONCAT(ol.OutcomeDescription, ' - ', subtype.OutcomeDescription), IsFinal = 1
	FROM [dbo].PeriodicOutcome po
	INNER JOIN 
		(
		SELECT DISTINCT te.NotificationId, te.TreatmentOutcomeId
		FROM [$(NTBS)].dbo.TreatmentEvent te
			LEFT JOIN [$(NTBS)].dbo.TreatmentEvent te2 ON te2.NotificationId = te.NotificationId AND te.EventDate <= te2.EventDate
			LEFT JOIN [$(NTBS)].dbo.TreatmentEvent te3 ON te3.NotificationId = te.NotificationId
				AND te.TreatmentEventId <> te3.TreatmentEventId
				AND te2.TreatmentEventId <> te3.TreatmentEventId
			JOIN [$(NTBS)].dbo.ClinicalDetails cd ON cd.NotificationId = te.NotificationId
		WHERE cd.IsPostMortem = 1
			AND te.TreatmentOutcomeId IN (7, 8, 9, 10)
			AND (te2.TreatmentEventType = 'DiagnosisMade' OR te2.TreatmentEventId IS NULL)
			AND te3.TreatmentEventId IS NULL
		) AS Q1 ON Q1.NotificationId = po.NotificationId
	LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[TreatmentOutcome] tro ON tro.TreatmentOutcomeId = Q1.TreatmentOutcomeId
	LEFT OUTER JOIN [dbo].[OutcomeLookup] ol ON ol.OutcomeCode = tro.TreatmentOutcomeType
	LEFT OUTER JOIN [dbo].[OutcomeLookup] subtype ON subtype.OutcomeCode = tro.TreatmentOutcomeSubType
	WHERE TimePeriod = 1

END TRY
BEGIN CATCH
	THROW
END CATCH