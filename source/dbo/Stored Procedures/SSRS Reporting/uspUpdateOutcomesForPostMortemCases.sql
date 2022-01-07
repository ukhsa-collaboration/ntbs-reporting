CREATE PROCEDURE [dbo].[uspUpdateOutcomesForPostMortemCases]
AS
BEGIN TRY
	UPDATE po SET OutcomeValue = 'Died', IsFinal = 1
	FROM [dbo].PeriodicOutcome po
	WHERE po.NotificationId IN
		(
		SELECT DISTINCT te.NotificationId
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
		)
		AND TimePeriod = 1

END TRY
BEGIN CATCH
	THROW
END CATCH