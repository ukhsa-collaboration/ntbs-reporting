/*this will be used to confirm to regional staff which notifications will be included in their data migration.
It will include:
- all notified cases from 2017 which are being TREATED in the region
- all denotified cases from the last 18 months (as all other denotified cases are ignored anyway
- any groups of records included
*/


CREATE PROCEDURE [dbo].[uspConfirmationLineList]
	@Region VARCHAR(50)		=	NULL

AS


	WITH NotificationGroups AS
	(SELECT DISTINCT(GroupId) 
	FROM [$(migration)].[dbo].[MergedNotifications] mn 
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = mn.NtbsHospitalId
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
	WHERE 
		mn.GroupId IS NOT NULL
		AND p.PHEC_Name = @Region
		AND mn.NotificationDate >= '2017-01-01'),
	LinkedNotifications AS
	(SELECT ng.GroupId, STRING_AGG(CAST(mn.PrimaryNotificationId AS NVARCHAR(MAX)), ', ') AS LinkedNotifications
	FROM [$(migration)].[dbo].[MergedNotifications] mn 
	INNER JOIN NotificationGroups ng ON ng.GroupId = mn.GroupId
	GROUP BY ng.GroupId)

	SELECT 
		EtsId					AS 'EtsId', 
		LtbrId					AS 'LtbrNo', 
		PrimarySource			AS 'SourceSystem', 
		OldHospitalName			AS 'LegacyHospital', 
		p.PHEC_Name				AS 'Region', 
		NotificationDate, 
		CASE 
			WHEN IsDenotified = 1 THEN 'Yes' 
			ELSE 'No' 
		END						AS 'Denotified', 
		DenotificationDate		AS 'DenotificationDate', 
		CaseManager				AS 'CaseManager', 
		tbs.TB_Service_Name		AS 'TBServiceName', 
		ln.LinkedNotifications	AS 'LinkedNotifications'
	FROM [$(migration)].[dbo].[MergedNotifications] mn 
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = mn.NtbsHospitalId
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs ON tbs.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
		LEFT OUTER JOIN NotificationGroups ng ON ng.GroupId = mn.GroupId
		LEFT OUTER JOIN LinkedNotifications ln ON ln.GroupId = mn.GroupId
	WHERE 
		ng.GroupId IS NOT NULL
	OR 
		(p.PHEC_Name = @Region AND mn.NotificationDate >= '2017-01-01')

	ORDER BY mn.NotificationDate DESC
	
RETURN 0
