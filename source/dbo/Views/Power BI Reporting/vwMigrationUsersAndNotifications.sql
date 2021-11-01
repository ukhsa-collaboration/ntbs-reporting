CREATE VIEW [dbo].[vwMigrationUsersAndNotifications]
	AS 
	SELECT 
		su.Username, 
		su.PermissionId, su.Email, 
		dbo.ufnStripNonAlphaChars( su.Surname) AS Surname, 
		su.Forename, 
		tbs.TB_Service_Name, 
		h.HospitalName, 
		tbs.IsLegacy AS TbServiceIsLegacy, 
		h.IsLegacy AS HospitalIsLegacy, 
		1 AS LegacyId, 
		n.NotificationDate, 
		p.PHEC_Code AS TreatmentPhec
	FROM [$(OtherServer)].[$(ETS)].[dbo].[SystemUser] su
		--inner join with the ETS_Notifications view in the migration database, so we only consider migratable notifications
		INNER JOIN [$(migration)].[dbo].[ETS_Notification] n ON n.OwnerUserId = su.Id
		INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h ON H.HospitalId = n.HospitalId
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = h.HospitalId
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs ON tbs.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbp ON tbp.TB_Service_Code = tbs.TB_Service_Code
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Code = tbp.PHEC_Code
	WHERE n.NotificationDate >= '2018-01-01' AND su.AuditSuspended IS NULL AND su.AuditDelete IS NULL