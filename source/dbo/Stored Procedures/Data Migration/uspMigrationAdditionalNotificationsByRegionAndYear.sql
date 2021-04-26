CREATE PROCEDURE [dbo].[uspMigrationAdditionalNotificationsByRegionAndYear]
	@Region VARCHAR(50)		=	NULL
AS


	--we want to display a list of the additional notifications which will be migrated as part of a particular region's migration.
	--these are records linked to the selected notifications, which may be outside the chosen the region OR outside the time period


	--first find the groups
	WITH NotificationGroups AS
	(SELECT DISTINCT(GroupId) 
	FROM [$(migration)].[dbo].[MergedNotifications] mn 
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = mn.NtbsHospitalId
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
		LEFT JOIN vwNotificationYear ny ON ny.NotificationYear = YEAR(mn.NotificationDate)
	WHERE 
	mn.GroupId IS NOT NULL
	AND p.PHEC_Name = @Region
	AND ny.Id >= -3)

	SELECT DATEPART(YEAR, NotificationDate) AS 'NotificationYear', p.PHEC_Name AS Region, COUNT(PrimaryNotificationId) AS CountOfRecords  
	FROM [$(migration)].[dbo].[MergedNotifications] mn 
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = mn.NtbsHospitalId
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
		LEFT JOIN vwNotificationYear ny ON ny.NotificationYear = YEAR(mn.NotificationDate)
		INNER JOIN NotificationGroups ng ON ng.GroupId = mn.GroupId
	WHERE mn.GroupId IS NOT NULL
	AND
	(p.PHEC_Name != @Region OR ny.Id < -3 OR ny.Id IS NULL)
	AND NOT EXISTS
		(SELECT NotificationId
		FROM [$(NTBS)].[dbo].Notification ntbsn
		WHERE ntbsn.ETSID = mn.EtsID OR ntbsn.LTBRID = mn.LtbrID)
	GROUP BY DATEPART(YEAR, NotificationDate), p.PHEC_Name
	ORDER BY DATEPART(YEAR, NotificationDate), p.PHEC_Name DESC 
RETURN 0
