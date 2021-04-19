CREATE PROCEDURE [dbo].[uspMigrationSelectedNotificationsByYear]
	@Region VARCHAR(50)		=	NULL
AS
	SELECT DATEPART(YEAR, NotificationDate) AS 'NotificationYear', COUNT(PrimaryNotificationId) AS CountOfRecords 
	FROM [$(migration)].[dbo].[MergedNotifications] mn 
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = mn.NtbsHospitalId
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
	LEFT JOIN vwNotificationYear ny ON ny.NotificationYear = YEAR(mn.NotificationDate)
	WHERE p.PHEC_Name = @Region AND ny.Id >= -3
	AND NOT EXISTS
		(SELECT NotificationId
		FROM [$(NTBS)].[dbo].Notification ntbsn
		WHERE ntbsn.ETSID = mn.EtsID OR ntbsn.LTBRID = mn.LtbrID)
	GROUP BY DATEPART(YEAR, NotificationDate)
	ORDER BY DATEPART(YEAR, NotificationDate) DESC 
RETURN 0
