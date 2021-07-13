CREATE PROCEDURE [dbo].[uspSummarisedNTBSMatches]
	@StartDate DATE
AS
	SELECT  
		'NTBS' AS 'System', 
		DATEPART(YEAR, UpdateDateTime) AS 'Year', 
		SUM(CASE WHEN MatchType = 'Confirmed' THEN 1 ELSE 0 END) AS 'NumberOfConfirmedMatches', 
		SUM(CASE WHEN MatchMethod = 'Automatch' THEN 1 ELSE 0 END) AS 'NumberOfAutomatches',
		SUM(CASE WHEN MatchMethod = 'Manual-ConfidenceLevel' THEN 1 ELSE 0 END) AS 'NumberOfConfidenceLevelMatches',
		SUM(CASE WHEN MatchMethod = 'Manual' THEN 1 ELSE 0 END) AS NumberOfManualMatches,
		SUM(CASE WHEN MatchType = 'Possible' THEN 1 ELSE 0 END) AS 'NumberOfPotentialMatches',
		SUM(CASE WHEN MatchType = 'Rejected' THEN 1 ELSE 0 END) AS 'NumberOfRejectedMatches'
	FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch] 
	WHERE  (MatchMethod != 'Migration' or MatchMethod is null)
		AND UpdateDateTime >= @StartDate
	GROUP BY DATEPART(YEAR, UpdateDateTime)
RETURN 0
