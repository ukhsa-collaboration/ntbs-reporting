CREATE PROCEDURE [dbo].[uspMirgationSpecimensMatchesToReview]
	@MigrationRun INT = NULL
AS
	SELECT
		mrr.MigrationNotificationId							AS 'MigrationNotificationId',
		mrr.LegacyETSId										AS 'EtsId',
		mrr.NTBSNotificationId								AS 'NtbsId',
		mdsm.ReferenceLaboratoryNumber						AS 'ReferenceLaboratoryNumber',
		esm.SpecimenDate									AS 'SpecimenDate',
		mrr.NotificationDate								AS 'NotificationDate',
		dbo.ufnGetTreatmentEndDate(mrr.NTBSNotificationId)	AS 'TreatmentEndDate',
		mdsm.MigrationNotes									AS 'MigrationNotes'
	FROM [dbo].[MigrationRunResults] mrr
		INNER JOIN [dbo].[MigrationDubiousSpecimenMatches] mdsm ON mdsm.EtsId = mrr.LegacyETSId
		INNER JOIN [$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch] esm ON esm.LegacyId = mdsm.EtsId AND esm.ReferenceLaboratoryNumber = mdsm.ReferenceLaboratoryNumber
	WHERE MigrationRunId = @MigrationRun
