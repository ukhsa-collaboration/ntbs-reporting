CREATE PROCEDURE [dbo].[uspGenerateMigrationMasterList]
	
AS
	TRUNCATE TABLE [dbo].[MigrationMasterList]
	

	INSERT INTO [dbo].[MigrationMasterList](OldNotificationId, OldHospitalId, OldHospitalName, NtbsHospitalId, EtsID, LtbrId, GroupId, NotificationDate, Denotified, DenotificationDate, SourceSystem, Region, 
		LinkedNotifications, NotificationYear)
	SELECT [OldNotificationId]					AS 'OldNotificationId'
      ,[OldHospitalId]							AS 'OldHospitalId'
      ,[OldHospitalName]						AS 'OldHospitalName'
      ,[NtbsHospitalId]							AS 'NtbsHospitalId'
      ,[EtsID]									AS 'EtsId'
      ,[LtbrId]									AS 'LtbrId'
      ,pf.[GroupId]								AS 'GroupId'
      ,[NotificationDate]						AS 'NotificationDate'
      ,CASE
		WHEN [IsDenotified] = 1 THEN 'Yes'
		ELSE 'No'
		END										AS 'Denotified'
      ,[DenotificationDate]
      ,CASE
		WHEN [LTBRIsPrimary] = 1 THEN 'LTBR'
		ELSE 'ETS'
		END										AS 'SourceSystem'
	  ,p.PHEC_Name								AS 'Region'	
	  ,Q1.LinkedNotifications					AS 'LinkedNotifications'
	  ,DATEPART(YEAR, NotificationDate)			AS 'NotificationYear'
	FROM [$(migration)].[dbo].[EtsRecordsWithIsPrimaryFlag] pf
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h ON h.HospitalId = pf.OldHospitalId
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = h.HospitalId
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN  [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbsp.PHEC_Code
		LEFT OUTER JOIN
				(SELECT GroupId, STRING_AGG(OldNotificationId, ', ') AS 'LinkedNotifications'
				 FROM [$(migration)].[dbo].[EtsRecordsWithIsPrimaryFlag]
				 WHERE GroupId IS NOT NULL
				 GROUP BY GroupId) AS Q1 ON Q1.GroupId = pf.GroupId


RETURN 0
