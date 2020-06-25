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
			(CASE Homeless WHEN 'Yes' THEN 1 ELSE 0 END) AS Homeless,
			cluster.ClusterId
		FROM dbo.ReusableNotification n WITH (NOLOCK)
		INNER JOIN NotificationClusterMatch cluster ON cluster.NotificationId = n.NotificationId
		WHERE ClusterId = @ClusterId
	),
	MedianCalc(MedianAge) AS
	(
		SELECT DISTINCT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Age)
			OVER (PARTITION BY ClusterId) AS MedianAge
			FROM notificationsInCluster
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
		--there is only one value for MedianAge but the select requires all values to be in aggregate form
		MAX(MedianAge) AS MedianAge
	FROM notificationsInCluster, MedianCalc
END