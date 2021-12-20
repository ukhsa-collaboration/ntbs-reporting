/***************************************************************************************************
Desc:    This SQL query goes 3 calendar years back, eg when in 2019 the following would only include
         notifications starting from '2016-01-01'. This DB view is used for the following 2 purposes:
		 a) This restricts the notification generation query that runs every night to the lst 3 years.
		 b) This also returns drop-down values of the 12 years, which are used for the end-user to filter
         on the notification start/end months.


         
**************************************************************************************************/

CREATE VIEW [dbo].[vwNotificationYear] AS
	SELECT TOP 5 
		Id,
		NotificationYear
	FROM (
			SELECT
				0 AS Id,
				YEAR(GETDATE()) AS NotificationYear
			UNION
			SELECT
				-1 AS Id,
				YEAR(DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) -1, 0)) AS NotificationYear
			UNION
			SELECT
				-2 AS Id,
				YEAR(DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) -2, 0)) AS NotificationYear
			UNION
			SELECT
				-3 AS Id,
				YEAR(DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) -3, 0)) AS NotificationYear
			UNION
			SELECT
				-4 AS Id,
				YEAR(DATEADD(YEAR, DATEDIFF(YEAR, 0, GETDATE()) -4, 0)) AS NotificationYear
		) NotificationYear
	ORDER BY NotificationYear DESC
