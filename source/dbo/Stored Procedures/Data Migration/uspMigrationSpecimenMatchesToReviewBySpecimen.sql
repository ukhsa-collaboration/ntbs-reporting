CREATE PROCEDURE [dbo].[uspMigrationSpecimenMatchesToReviewBySpecimen]
	@MigrationRun INT = NULL
AS
	WITH DubiousMatchesFromMigration AS
	(
		SELECT mdsm.ReferenceLaboratoryNumber
		FROM [dbo].[MigrationRunResults] mrr
			INNER JOIN [dbo].[MigrationDubiousSpecimenMatches] mdsm ON mdsm.EtsId = mrr.LegacyETSId
		WHERE MigrationRunId = @MigrationRun
	)

	SELECT
		mrr.MigrationNotificationId								AS 'MigrationNotificationId',
		etsn.LegacyId											AS 'EtsId',
		CASE
			WHEN etsn.DenotificationId IS NOT NULL THEN 'Denotified'
			WHEN etsn.Submitted = 0 THEN 'Draft'
			ELSE 'Notified'
		END														AS 'EtsStatus',
		ntbsn.NotificationId									AS 'NtbsId',
		mdsm.ReferenceLaboratoryNumber							AS 'ReferenceLaboratoryNumber',
		esm.SpecimenDate										AS 'SpecimenDate',
		ntbsn.NotificationDate									AS 'NotificationDate',
		dbo.ufnGetTreatmentEndDate(ntbsn.NotificationId)		AS 'TreatmentEndDate',
		mdsm.MigrationNotes										AS 'MigrationNotes'
	FROM [dbo].[MigrationDubiousSpecimenMatches] mdsm
		LEFT JOIN [dbo].[MigrationRunResults] mrr ON mdsm.EtsId = mrr.LegacyETSId
		LEFT JOIN [$(ETS)].[dbo].[Notification] etsn ON etsn.LegacyId = mdsm.EtsId
		LEFT JOIN [$(NTBS)].[dbo].[Notification] ntbsn ON ntbsn.ETSID = mdsm.EtsId
		INNER JOIN [$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch] esm ON esm.LegacyId = mdsm.EtsId AND esm.ReferenceLaboratoryNumber = mdsm.ReferenceLaboratoryNumber
	WHERE mdsm.ReferenceLaboratoryNumber IN (SELECT * FROM DubiousMatchesFromMigration)
