CREATE PROCEDURE [dbo].[uspCountOfClusterNotificationsPerMonth]
	@ClusterId NVARCHAR(50) = NULL
AS
	--get a list of all the months between the first notification in the cluster and the last
	WITH YearAndMonth(YearMonthValue) AS
		(SELECT DISTINCT [YearMonthValue]
		FROM [dbo].[Calendar] c
		WHERE c.DateValue >= (SELECT MIN(rn.NotificationDate) FROM [dbo].[ReusableNotification] rn
			INNER JOIN [dbo].[NotificationClusterMatch] ncm ON ncm.NotificationId = rn.NotificationId
		WHERE ncm.ClusterId = @ClusterId)
		and c.DateValue <= (SELECT MAX(rn.NotificationDate) FROM [dbo].[ReusableNotification] rn
		INNER JOIN [dbo].[NotificationClusterMatch] ncm ON ncm.NotificationId = rn.NotificationId
		WHERE ncm.ClusterId = @ClusterId)),

		--then a count of notifications by month
		CountByMonth(YearMonthValue, CountByMonth) AS
			(SELECT c.YearMonthValue, Count(rn.NotificationId) as 'CountByMonth' FROM [dbo].[ReusableNotification] rn
				INNER JOIN [dbo].[NotificationClusterMatch] ncm ON ncm.NotificationId = rn.NotificationId
				INNER JOIN [dbo].[Calendar] c ON c.DateValue = rn.NotificationDate
			WHERE ncm.ClusterId = @ClusterId
			GROUP BY c.YearMonthValue)


	SELECT y.YearMonthValue, COALESCE(c.CountByMonth, 0) AS CountByMonth 
		FROM YearAndMonth y 
		LEFT OUTER JOIN CountByMonth c ON c.YearMonthValue = y.YearMonthValue
RETURN 0
