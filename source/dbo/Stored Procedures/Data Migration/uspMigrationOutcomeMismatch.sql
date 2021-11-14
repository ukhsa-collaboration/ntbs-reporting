/*
	Note that this stored procdure will exclude some expected mismatches (see below) to focus on
	where there may be more complex data cleaning to do.

	Expected mismatches:
	ETS (reporting)		NTBS					Reason
	=================================================================================
	Not evaluated		No outcome recorded		'Not evaluated' is a real outcome value in NTBS, but wasn't in ETS so in the reporting service we would output it as 'Not evaluated'
	Unknown				Not evaluated			Agreed mapping for this outcome
	Still on treatment	Not evaluated			'Still on treatment' is a sub-type value in NTBS
*/

CREATE PROCEDURE [dbo].[uspMigrationOutcomeMismatch]
	@MigrationRun INT = NULL
AS

	--work out which notifications have genuinely mismatched outcomes
	WITH EtsMismatches AS
	(
		SELECT
			mrr.MigrationNotificationId		AS 'MigrationNotificationId'
		FROM [dbo].[MigrationRunResults] mrr
			LEFT JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = mrr.NTBSNotificationId
		WHERE
			n.NotificationStatus != 'Denotified'
			AND mrr.EtsTreatmentOutcome != mrr.NTBSTreatmentOutcome
			AND NOT(mrr.EtsTreatmentOutcome = 'Not evaluated' AND mrr.NTBSTreatmentOutcome = 'No outcome recorded')
			AND NOT(mrr.EtsTreatmentOutcome = 'Unknown' AND mrr.NTBSTreatmentOutcome = 'Not evaluated')
			AND NOT(mrr.EtsTreatmentOutcome = 'Still on treatment' AND mrr.NTBSTreatmentOutcome = 'Not evaluated')
			AND mrr.SourceSystem = 'ETS'
			AND mrr.MigrationRunId = @MigrationRun
	),
	LtbrMismatches AS
	(
		
		SELECT
			mrr.MigrationNotificationId		AS 'MigrationNotificationId'
		FROM [dbo].[MigrationRunResults] mrr
			LEFT JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = mrr.NTBSNotificationId
			LEFT OUTER JOIN [$(migration)].[dbo].[LtbrTreatmentOutcomesMapping] map ON map.LtbrId = mrr.LegacyOutcomeId AND map.NtbsId = mrr.NTBSOutcomeId
		WHERE
			n.NotificationStatus != 'Denotified'
			AND mrr.SourceSystem = 'LTBR'
			AND mrr.MigrationRunId = @MigrationRun
			AND NOT(mrr.EtsTreatmentOutcome = 'No outcome recorded' AND mrr.NTBSTreatmentOutcome = 'No outcome recorded')
			AND map.LtbrId IS NULL
	),
	AllMismatches AS
	(
		SELECT * FROM EtsMismatches
		UNION
		SELECT * FROM LtbrMismatches
	),
	EventOrder AS
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
		INNER JOIN AllMismatches a ON a.MigrationNotificationId = mrr.MigrationNotificationId
		LEFT JOIN [$(NTBS)].[dbo].[TreatmentEvent] te ON te.NotificationId = mrr.NTBSNotificationId
		LEFT JOIN EventOrder ev ON ev.EventName = te.TreatmentEventType
		LEFT JOIN [$(NTBS)].[ReferenceData].[TreatmentOutcome] tout ON tout.TreatmentOutcomeId = te.TreatmentOutcomeId
		LEFT JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = mrr.NTBSNotificationId
	WHERE mrr.MigrationRunId = @MigrationRun
	ORDER BY mrr.MigrationNotificationId, te.EventDate DESC, ev.OrderBy DESC
