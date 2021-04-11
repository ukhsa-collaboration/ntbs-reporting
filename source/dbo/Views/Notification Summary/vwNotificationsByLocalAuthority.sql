CREATE VIEW [dbo].[vwNotificationsByLocalAuthority]
	AS
	--get the local authorities
	WITH LocalAuthority AS
	(SELECT la.[LA_Code]
      ,la.[LA_Name]
	FROM [$(NTBS_R1_Geography_Staging)].[dbo].[Local_Authority] la
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
		COALESCE(LocalAuthorityCode, 'UNKNOWN') AS LocalAuthorityCode, 
		c.YearMonthValue AS YearMonth,
		COUNT(NotificationId) AS NotificationCount
	FROM [dbo].vwNotifiedRecords nr
		LEFT OUTER JOIN [dbo].[Calendar] c ON c.DateValue = nr.NotificationDate
	GROUP BY COALESCE(LocalAuthorityCode, 'UNKNOWN'), c.YearMonthValue)

	--then cross join to produce one row for each combination of year/month and local authority
	SELECT 
		m.YearMonthValue, 
		m.FirstOfMonthValue, 
		la.LA_Code, 
		la.LA_Name, 
	COALESCE(c.NotificationCount, 0) AS NotificationCount
	FROM Months m
		CROSS JOIN LocalAuthority la
		LEFT OUTER JOIN CountedNotifications c ON c.YearMonth = m.YearMonthValue AND c.LocalAuthorityCode = la.LA_Code
