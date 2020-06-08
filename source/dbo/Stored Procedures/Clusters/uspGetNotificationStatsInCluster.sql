CREATE PROCEDURE [dbo].[uspGetNotificationStatsInCluster]
(
	@ClusterId VARCHAR(200)
)
AS
BEGIN
	WITH notificationsInCluster AS
	(
		SELECT NotificationDate,
			BirthCountry, 
			Sex,
			Age,
			(CASE AlcoholMisuse WHEN 'Yes' THEN 1 ELSE 0 END) AS Alcohol,
			(CASE DrugMisuse WHEN 'Yes' THEN 1 ELSE 0 END) AS Drug,
			(CASE Prison WHEN 'Yes' THEN 1 ELSE 0 END) AS Prison,
			(CASE Homeless WHEN 'Yes' THEN 1 ELSE 0 END) AS Homeless
		FROM dbo.ReusableNotification n WITH (NOLOCK)
		LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = (CASE WHEN n.NtbsId IS NULL THEN n.EtsId ELSE n.NtbsId END)
		WHERE ClusterId = @ClusterId
	)

	SELECT
		MIN(NotificationDate) AS EarliestNotificationDate,
		MAX(NotificationDate) AS LatestNotificationDate,
		SUM(CASE Sex WHEN 'Male' THEN 1 ELSE 0 END) AS MaleCount,
		SUM(CASE Sex WHEN 'Female' THEN 1 ELSE 0 END) AS FemaleCount,
		SUM(Alcohol) AS AlcoholCount,
		SUM(Homeless) AS HomelessCount,
		SUM(Drug) AS DrugCount,
		SUM(Prison) AS PrisonCount,
		COUNT(NotificationDate) AS TotalCount,
		MIN(Age) AS MinAge,
		MAX(Age) AS MaxAge,
		AVG(Age) AS MedianAge
	FROM notificationsInCluster
END