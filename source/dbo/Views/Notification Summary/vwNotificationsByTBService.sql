CREATE VIEW [dbo].[vwNotificationsByTBService]
	AS 
	WITH TbService AS
	(SELECT [TB_Service_Code] AS TbServiceCode
      ,[TB_Service_Name]
	FROM [dbo].[TB_Service]
	UNION
	SELECT 'UNKNOWN', 'UNKNOWN'),

	-- Get the list of months. The first of month value will allow it to be associated to a specific row
	-- in the Power BI calendar table
	Months AS
	(SELECT DISTINCT [YearMonthValue], [FirstOfMonthValue]
	FROM [dbo].[Calendar]
	WHERE YearValue IN (SELECT NotificationYear FROM [dbo].[vwNotificationYear])),

	--count the notifications
	CountedNotifications AS
	(SELECT 
		COALESCE(TBServiceCode, 'UNKNOWN') AS TbServiceCode, 
		c.YearMonthValue AS YearMonth,
		COUNT(nr.NotificationId) AS NotificationCount,
		SUM(CASE cr.CulturePositive WHEN 'Yes' THEN 1 ELSE 0 END) AS CulturePositiveCount
	FROM [dbo].vwNotifiedRecords nr
		INNER JOIN [dbo].[Record_CultureAndResistance] cr ON cr.NotificationId = nr.NotificationId
		LEFT OUTER JOIN [dbo].[Calendar] c ON c.DateValue = nr.NotificationDate
	GROUP BY COALESCE(TbServiceCode, 'UNKNOWN'), c.YearMonthValue)

	--then cross join to produce one row for each combination of year/month and local authority
	SELECT 
		m.YearMonthValue, 
		m.FirstOfMonthValue, 
		tbs.TbServiceCode, 
		tbs.TB_Service_Name, 
		COALESCE(c.NotificationCount, 0) AS NotificationCount,
		COALESCE(c.CulturePositiveCount, 0) AS CulturePositiveCount
	FROM Months m
		CROSS JOIN TbService tbs
		LEFT OUTER JOIN CountedNotifications c ON c.YearMonth = m.YearMonthValue AND c.TbServiceCode = tbs.TbServiceCode