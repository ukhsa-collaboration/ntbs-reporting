CREATE PROCEDURE [dbo].[uspGetNotificationStatsInCluster]
(
	@ClusterId VARCHAR(200)
)
AS
BEGIN

	DECLARE @MedianAge INT = 0;

	--Calculate median using PERCENTILE_DISC. This will always choose one of the values in the list
	SELECT DISTINCT @MedianAge = PERCENTILE_DISC(0.5) WITHIN GROUP (ORDER BY Age)
			OVER (PARTITION BY ClusterId)
			FROM [dbo].ReusableNotification rn
				INNER JOIN [dbo].[NotificationClusterMatch] ncm ON ncm.NotificationId = rn.NotificationId
				WHERE ncm.ClusterId = @ClusterId;


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
		INNER JOIN NotificationClusterMatch cluster ON cluster.NotificationId = n.NotificationId
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
		@MedianAge AS MedianAge
	FROM notificationsInCluster
END