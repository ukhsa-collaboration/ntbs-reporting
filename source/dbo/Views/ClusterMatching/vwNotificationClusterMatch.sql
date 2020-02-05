/***************************************************************************************************
Desc:    View for purposes of representing changes that need to be made in NTBS to reflect
		 the current state of cluster matching to NTBS records.
         
**************************************************************************************************/

CREATE VIEW [dbo].[vwNotificationClusterMatch]
	AS 
	
		/*
			Include records from the reporting database when they are in parity
			with NTBS cached version of the cluster matching.
		*/
		SELECT 
			ncm1.NotificationId, 
			ncm1.ClusterId
		FROM [dbo].[NotificationClusterMatch] ncm1
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Notification] n1
			ON n1.NotificationId = ncm1.NotificationId
		WHERE 
			ncm1.ClusterId <> n1.ClusterId
			OR n1.ClusterId IS NULL

		UNION ALL

		/*
			Also include records where NTBS contains a value, but reporting
			does not have a value. Hypothetically a cluster was unmatched to
			the notification.
		*/
		SELECT 
			n2.NotificationId,
			NULL AS ClusterId
		FROM [$(NTBS)].[dbo].[Notification] n2
		LEFT OUTER JOIN [dbo].[NotificationClusterMatch] ncm2
			ON n2.NotificationId = ncm2.NotificationId
		WHERE 
			n2.ClusterId IS NOT NULL
			AND ncm2.NotificationId IS NULL
