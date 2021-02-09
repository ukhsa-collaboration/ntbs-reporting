CREATE VIEW [dbo].[vwMigrationDubiousSpecimenMatches]
	AS 
	SELECT EtsId,'Review specimen match(es) to Isolate(s) ' + STRING_AGG ( MigrationNotes, ', ')  AS MigrationNotes   
	FROM MigrationDubiousSpecimenMatches
	GROUP BY EtsId
