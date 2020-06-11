CREATE PROCEDURE [dbo].[uspGetTopBirthCountriesInCluster] (
	@ClusterId VARCHAR(200)
)
AS
BEGIN
	WITH notificationsInCluster AS
	(
		SELECT BirthCountry
		FROM dbo.ReusableNotification n WITH (NOLOCK)
		LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = n.NotificationId
		WHERE ClusterId = @ClusterId
	)

	SELECT TOP 3 
		BirthCountry, 
		Count(BirthCountry) AS CountryCount
	FROM notificationsInCluster
	GROUP BY BirthCountry
	ORDER BY CountryCount DESC
END