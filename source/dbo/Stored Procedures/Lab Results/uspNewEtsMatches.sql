CREATE PROCEDURE [dbo].[uspNewEtsMatches]
	@RecentDate DATETIME = NULL
AS
	SELECT 
		'ETS' AS 'System', 
		COUNT(LegacyId) AS 'NumberOfNewMatches', 
		SUM(Denotified) AS NumberOfDenotifiedRecords, 
		SUM(Draft) AS NumberOfDraftRecords, 
		SUM(Automatched) AS NumberOfAutomatches 
	FROM
		[$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch] 
	WHERE EarliestMatchDate >=  DATEADD(DAY, -3, @RecentDate)
RETURN 0
