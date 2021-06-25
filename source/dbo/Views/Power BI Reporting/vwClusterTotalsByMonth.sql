CREATE VIEW [dbo].[vwClusterTotalsByMonth]
	AS 

	--get a count by month and running total for each cluster, for every month from the earliest notification date
	--to the current date
	--use FirstOfMonthValue so that Power BI can make use of its data hierarchy functionality (which is based on whole dates)

	
	--first get all the clusters
	WITH 
	Cluster AS
	(SELECT DISTINCT ClusterId, MIN(NotificationDate) AS MinDate 
	FROM [dbo].[RecordRegister]
	WHERE ClusterId IS NOT NULL
	GROUP BY ClusterId),

	--then get a list of all the months between the first notification in the cluster and today
	YearAndMonth AS
	(SELECT DISTINCT c.ClusterId, cal.FirstOfMonthValue
	FROM [dbo].[Calendar] cal, Cluster c
	WHERE cal.DateValue BETWEEN c.MinDate AND GETUTCDATE()),

	--then a count of notifications by month
	NotificationCountByMonth AS
	(SELECT rr.ClusterId, cal.FirstOfMonthValue, COUNT(rr.NotificationId) as 'CountByMonth' 
	FROM [dbo].[RecordRegister] rr
		INNER JOIN [dbo].[Calendar] cal ON cal.DateValue = rr.NotificationDate
	WHERE rr.ClusterId IS NOT NULL
	GROUP BY rr.ClusterId, cal.FirstOfMonthValue)


	SELECT y.ClusterId, y.FirstOfMonthValue, COALESCE(nc.CountByMonth, 0) AS CountByMonth, 
		SUM(nc.CountByMonth) OVER (PARTITION BY y.ClusterId ORDER BY y.FirstOfMonthValue) AS RunningTotal  
	FROM YearAndMonth y 
		LEFT OUTER JOIN NotificationCountByMonth nc ON nc.FirstOfMonthValue = y.FirstOfMonthValue AND nc.ClusterId = y.ClusterId