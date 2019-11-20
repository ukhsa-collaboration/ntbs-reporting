/***************************************************************************************************
Desc:    This returns drop-down values of the 12 months, which are used for the end-user to filter
         on the notification start/end months.


         
**************************************************************************************************/

CREATE VIEW [dbo].[vwNotificationMonth] AS
	SELECT TOP 12 
		Id,
		NotificationMonth
	FROM (
			SELECT
				1 AS Id,
				'January' AS NotificationMonth
			UNION ALL 
				SELECT
				2 AS Id,
				'February' AS NotificationMonth
			UNION ALL 
				SELECT 
				3 AS Id,
				'March' AS NotificationMonth
			UNION ALL 
				SELECT 
				4 AS Id,
				'April' AS NotificationMonth
			UNION ALL 
				SELECT
				5 AS Id,
				'May' AS NotificationMonth
			UNION ALL 
				SELECT
				6 AS Id,
				'June' AS NotificationMonth
			UNION ALL 
				SELECT
				7 AS Id,
				'July' AS NotificationMonth
			UNION ALL 
				SELECT
				8 AS Id,
				'August' AS NotificationMonth
			UNION ALL 
				SELECT
				9 AS Id,
				'September' AS NotificationMonth
			UNION ALL 
				SELECT
				10 AS Id,
				'October' AS NotificationMonth
			UNION ALL 
				SELECT
				11 AS Id,
				'November' AS NotificationMonth
			UNION ALL 
				SELECT
				12 AS Id,
				'December' AS NotificationMonth
		) NotificationMonth
	ORDER BY Id
