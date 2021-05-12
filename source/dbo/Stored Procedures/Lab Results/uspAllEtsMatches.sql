CREATE PROCEDURE [dbo].[uspAllEtsMatches]
AS
	SELECT 
		'ETS' AS 'System', 
		DATEPART(YEAR, EarliestMatchDate) AS 'Year',  
		COUNT(LegacyId) AS 'NumberOfNewMatches',  
		SUM(Automatched) AS NumberOfAutomatches, 
		SUM(Denotified) AS NumberOfDenotifiedRecords, 
		SUM(Draft) AS NumberOfDraftRecords 
	FROM
		[$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch]  esm
			INNER JOIN [dbo].[vwNotificationYear] ny ON ny.NotificationYear = YEAR(EarliestMatchDate)
	GROUP BY YEAR(EarliestMatchDate)
	ORDER BY YEAR(EarliestMatchDate)
RETURN 0
