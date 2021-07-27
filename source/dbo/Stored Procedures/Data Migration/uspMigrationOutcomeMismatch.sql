/*
	Note that we treat some outcomes as being equal even when they are actually different in NTBS and ETS.
	For more details see uspMigrationMisMatchedOutcomes.sql.
*/

CREATE PROCEDURE [dbo].[uspMigrationOutcomeMismatch]
	@MigrationRun INT = NULL
AS
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
		SELECT 'TreatmentOutcome' AS EventName, 6 AS 'OrderBy')

	SELECT
		mrr.MigrationNotificationId		AS 'MigrationNotificationId',
		mrr.LegacyETSId					AS 'EtsId',
		mrr.NTBSNotificationId			AS 'NtbsId',
		mrr.EtsTreatmentOutcome			AS 'EtsOutcome',
		mrr.NTBSTreatmentOutcome		AS 'NtbsOutcome',
		te.EventDate					AS 'EventDate',
		te.TreatmentEventType			AS 'EventType',
		tout.TreatmentOutcomeType		AS 'EventOutcome'
	FROM [dbo].[MigrationRunResults] mrr
		LEFT JOIN [$(NTBS)].[dbo].[TreatmentEvent] te ON te.NotificationId = mrr.NTBSNotificationId
		LEFT JOIN EventOrder ev ON ev.EventName = te.TreatmentEventType
		LEFT JOIN [$(NTBS)].[ReferenceData].[TreatmentOutcome] tout ON tout.TreatmentOutcomeId = te.TreatmentOutcomeId
	WHERE EtsTreatmentOutcome != NTBSTreatmentOutcome
		AND mrr.EtsTreatmentOutcome != mrr.NTBSTreatmentOutcome
		AND NOT(mrr.EtsTreatmentOutcome = 'Not evaluated' AND mrr.NTBSTreatmentOutcome = 'No outcome recorded')
		AND NOT(mrr.EtsTreatmentOutcome = 'Unknown' AND mrr.NTBSTreatmentOutcome = 'Not evaluated')
		AND NOT(mrr.EtsTreatmentOutcome = 'Still on treatment' AND mrr.NTBSTreatmentOutcome = 'Not evaluated')
		AND mrr.MigrationRunId = @MigrationRun
	ORDER BY mrr.MigrationNotificationId, te.EventDate DESC, ev.OrderBy DESC
