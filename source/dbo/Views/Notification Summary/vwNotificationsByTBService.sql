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
		COUNT(NotificationId) AS NotificationCount
	FROM [dbo].vwNotifiedRecords nr
		LEFT OUTER JOIN [dbo].[Calendar] c ON c.DateValue = nr.NotificationDate
	GROUP BY COALESCE(TbServiceCode, 'UNKNOWN'), c.YearMonthValue)

	--then cross join to produce one row for each combination of year/month and local authority
	SELECT 
		m.YearMonthValue, 
		m.FirstOfMonthValue, 
		tbs.TbServiceCode, 
		tbs.TB_Service_Name, 
	COALESCE(c.NotificationCount, 0) AS NotificationCount
	FROM Months m
		CROSS JOIN TbService tbs
		LEFT OUTER JOIN CountedNotifications c ON c.YearMonth = m.YearMonthValue AND c.TbServiceCode = tbs.TbServiceCode