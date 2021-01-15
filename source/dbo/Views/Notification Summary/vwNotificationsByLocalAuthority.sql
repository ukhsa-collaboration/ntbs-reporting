CREATE VIEW [dbo].[vwNotificationsByLocalAuthority]
	AS 
	WITH LocalAuthority AS
	(SELECT la.[LA_Code]
      ,la.[LA_Name]
	FROM [$(NTBS_R1_Geography_Staging)].[dbo].[Local_Authority] la
	UNION
	SELECT 'UNKNOWN', 'UNKNOWN'),

	-- Get the list of months
	Months AS
	(SELECT DISTINCT [YearMonthValue], FirstOfMonthValue
	FROM [dbo].[Calendar]
	WHERE YearValue IN (SELECT NotificationYear FROM [dbo].[vwNotificationYear])),
	Notifications AS
	(SELECT NotificationId, COALESCE(LocalAuthorityCode, 'UNKNOWN') AS LocalAuthorityCode, COALESCE([LocalAuthority], 'UNKNOWN') AS LocalAuthority,  DATEADD(DAY, 1, EOMONTH(NotificationDate, -1)) AS FirstOfMonth
	FROM [dbo].ReusableNotification rn),
	CountedNotifications AS
	(SELECT LocalAuthorityCode, LocalAuthority, FirstOfMonth, COUNT(NotificationId) AS NotificationCount
	FROM Notifications
	GROUP BY LocalAuthorityCode, LocalAuthority, FirstOfMonth)

	--SELECT * FROM CountedNotifications

	SELECT m.YearMonthValue, m.FirstOfMonthValue, FORMAT(m.FirstOfMonthValue, 'MMM yyyy') AS NotificationPeriod, la.LA_Code, la.LA_Name, COALESCE(c.NotificationCount, 0) AS NotificationCount
	FROM Months m
		CROSS JOIN LocalAuthority la
		LEFT OUTER JOIN CountedNotifications c ON c.FirstOfMonth = m.FirstOfMonthValue AND c.LocalAuthorityCode = la.LA_Code
