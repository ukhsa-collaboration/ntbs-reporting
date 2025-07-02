CREATE VIEW [dbo].[vwClusterSummary]
	AS 
	WITH Clusters AS
		(SELECT DISTINCT ClusterId
		FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationClusterMatch]),

	MedianCalc AS
	(
		SELECT DISTINCT rr.ClusterId, PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY cd.Age)
			OVER (PARTITION BY rr.ClusterId) AS MedianAge
			FROM [dbo].[RecordRegister] rr
				INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = rr.NotificationId
			WHERE rr.ClusterId IS NOT NULL
	)

	SELECT 
		c.ClusterId
		,COUNT(rr.NotificationId)			AS [Cases in cluster]
		,MIN(cd.Age)						AS [Min age]
		,MAX(cd.Age)						AS [Max age]
		--there is only one value for MedianAge but the select requires all values to be in aggregate form
		,MAX(m.MedianAge)					AS [Median age]
		,MIN(NotificationDate)				AS [Earliest notification date]
		,MAX(NotificationDate)				AS [Latest notification date]
		,SUM(
			CASE WHEN cd.Age < 15 THEN 1 
			ELSE 0 
			END)							AS [Child cases]
		,SUM(
			CASE WHEN cd.OccupationCategory = 'Health care worker' THEN 1 
			ELSE 0 
			END)							AS [Healthcare workers]
	FROM Clusters c
		INNER JOIN MedianCalc m ON m.ClusterId = c.ClusterId
		INNER JOIN [dbo].[RecordRegister] rr ON rr.ClusterId = c.ClusterId
		INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = rr.NotificationId
	GROUP BY c.ClusterId
	
	
