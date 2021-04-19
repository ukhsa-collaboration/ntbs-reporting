/*
This will produce the list of IDs to be migrated into NTBS
To prevent spurious errors, it includes a clause which will pick only one of any group of notifications within the time frame, so if a patient
was notified in 2017 and 2020, it will pick only one of the two records.

This prevents NTBS from trying to migrate the group twice. On the second attempt it will complain that the records already exist in NTBS.

*/

CREATE PROCEDURE [dbo].[uspMigrationLineList]
	@Region VARCHAR(50)		=	NULL

AS
	SELECT DISTINCT
		CASE WHEN GroupId IS NULL THEN PrimaryNotificationId
		ELSE
		FIRST_VALUE(PrimaryNotificationId) OVER (PARTITION BY GroupId ORDER BY PrimaryNotificationId) 
		END AS 'NotificationId'
	FROM [$(migration)].[dbo].[MergedNotifications] mn 
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = mn.NtbsHospitalId
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
		LEFT JOIN vwNotificationYear ny ON ny.NotificationYear = YEAR(mn.NotificationDate)
	WHERE 
	(p.PHEC_Name = @Region
	AND ny.Id >= -3)
	AND NOT EXISTS
		(SELECT NotificationId
		FROM [$(NTBS)].[dbo].Notification ntbsn
		WHERE ntbsn.ETSID = mn.EtsID OR ntbsn.LTBRID = mn.LtbrID)
RETURN 0
