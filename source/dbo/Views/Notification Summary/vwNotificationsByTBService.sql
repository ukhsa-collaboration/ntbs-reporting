CREATE VIEW [dbo].[vwNotificationsByTBService]
	AS 
	WITH TbService AS
	(SELECT [TB_Service_Code]
      ,[TB_Service_Name]
      ,[PHEC_Code]
      ,[PhecName]
	FROM [dbo].[TB_Service]),

	-- Get the list of months
	Months AS
	(SELECT DISTINCT [YearMonthValue], FirstOfMonthValue
	FROM [dbo].[Calendar]
	WHERE YearValue IN (SELECT NotificationYear FROM [dbo].[vwNotificationYear])),
	Notifications AS
	(SELECT NotificationId, COALESCE(TbServiceCode, 'UNKNOWN') AS TbServiceCode, COALESCE([Service], 'UNKNOWN') AS TbService,  DATEADD(DAY, 1, EOMONTH(NotificationDate, -1)) AS FirstOfMonth
	FROM [dbo].ReusableNotification rn),
	CountedNotifications AS
	(SELECT TbServiceCode, TbService, FirstOfMonth, COUNT(NotificationId) AS NotificationCount
	FROM Notifications
	GROUP BY TbServiceCode, TbService, FirstOfMonth)

	--SELECT * FROM CountedNotifications

	SELECT m.YearMonthValue, m.FirstOfMonthValue, FORMAT(m.FirstOfMonthValue, 'MMM yyyy') AS NotificationPeriod, tbs.TB_Service_Code, tbs.TB_Service_Name, COALESCE(c.NotificationCount, 0) AS NotificationCount
	FROM Months m
		CROSS JOIN TbService tbs
		LEFT OUTER JOIN CountedNotifications c ON c.FirstOfMonth = m.FirstOfMonthValue AND c.TbServiceCode = tbs.TB_Service_Code
