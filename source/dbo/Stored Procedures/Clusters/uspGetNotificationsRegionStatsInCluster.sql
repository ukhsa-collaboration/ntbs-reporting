CREATE PROCEDURE [dbo].[uspGetNotificationsRegionStatsInCluster]
(
	@ClusterId VARCHAR(200)
)
AS
BEGIN
	WITH notificationsInCluster AS
	(
		SELECT 
			ResidencePhec,
			ResidencePhecCode
		FROM dbo.ReusableNotification n WITH (NOLOCK)
		LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = n.NotificationId
		WHERE ClusterId = @ClusterId
	)

	SELECT
		ResidencePhec,
		MAX(ResidencePhecCode) AS ResidencePhecCode,
		COUNT(ResidencePhec) AS ResidencePhecCount
	FROM notificationsInCluster
	WHERE ResidencePhec IS NOT NULL
	GROUP BY ResidencePhec
	ORDER BY ResidencePhecCount DESC
END