CREATE PROCEDURE [dbo].[uspGetDrugResistanceStatsInCluster]
(
	@ClusterId VARCHAR(200)
)
AS
BEGIN
	WITH notificationsInCluster(NotificationId, DrugResistanceProfile) AS
	(
		SELECT 
			n.NotificationId, n.DrugResistanceProfile
		FROM dbo.ReusableNotification n WITH (NOLOCK)
		LEFT JOIN NotificationClusterMatch cluster ON cluster.NotificationId = n.NotificationId
		WHERE ClusterId = @ClusterId
	)

	SELECT
		DrugResistanceProfile,
		COUNT(NotificationId) AS CountOfDRP
	FROM notificationsInCluster

	GROUP BY DrugResistanceProfile
	ORDER BY CountOfDRP DESC
END