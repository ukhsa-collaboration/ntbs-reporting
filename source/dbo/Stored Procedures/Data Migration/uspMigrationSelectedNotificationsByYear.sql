CREATE PROCEDURE [dbo].[uspMigrationSelectedNotificationsByYear]
	@Region VARCHAR(50)		=	NULL
AS
	SELECT DATEPART(YEAR, NotificationDate) AS 'NotificationYear', COUNT(PrimaryNotificationId) AS CountOfRecords 
	FROM [$(migration)].[dbo].[MergedNotifications] mn 
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = mn.NtbsHospitalId
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
	LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
	WHERE p.PHEC_Name = @Region AND mn.NotificationDate >= '2017-01-01'
	GROUP BY DATEPART(YEAR, NotificationDate)
	ORDER BY DATEPART(YEAR, NotificationDate) DESC 
RETURN 0
