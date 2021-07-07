CREATE VIEW [dbo].[vwNotifications]
	AS 
	SELECT 
		NotificationId, 
		NotificationStatus, 
		ETSID, 
		LTBRID, 
		CreationDate, 
		SubmissionDate
	FROM [$(NTBS)].[dbo].[Notification]
