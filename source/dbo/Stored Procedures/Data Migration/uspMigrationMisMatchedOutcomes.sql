/*this will return the number of records in a particular migration run where the outcome calculated from ETS doesn't
correspond to the outcome calculated in NTBS. It will exclude some expected mismatches (see below) to focus on
where there may be more complex data cleaning to do.

Expected mismatches:
ETS (reporting)		NTBS					Reason
=================================================================================
Not evaluated		No outcome recorded		'Not evaluated' is a real outcome value in NTBS, but wasn't in ETS so in the reporting service we would output it as 'Not evaluated'
Unknown				Not evaluated			Agreed mapping for this outcome
Still on treatment	Not evaluated			'Still on treatment' is a sub-type value in NTBS
*/


CREATE PROCEDURE [dbo].[uspMigrationMisMatchedOutcomes]
	@MigrationRun INT = NULL
AS
	SELECT EtsTreatmentOutcome, NTBSTreatmentOutcome, COUNT(MigrationNotificationId) AS 'RecordCount'
	FROM [dbo].[MigrationRunResults] mrr
	WHERE mrr.MigrationRunId = @MigrationRun
	AND mrr.EtsTreatmentOutcome != mrr.NTBSTreatmentOutcome
	AND NOT(mrr.EtsTreatmentOutcome = 'Not evaluated' AND mrr.NTBSTreatmentOutcome = 'No outcome recorded')
	AND NOT(mrr.EtsTreatmentOutcome = 'Unknown' AND mrr.NTBSTreatmentOutcome = 'Not evaluated')
	AND NOT(mrr.EtsTreatmentOutcome = 'Still on treatment' AND mrr.NTBSTreatmentOutcome = 'Not evaluated')
	GROUP BY EtsTreatmentOutcome, NTBSTreatmentOutcome
RETURN 0
