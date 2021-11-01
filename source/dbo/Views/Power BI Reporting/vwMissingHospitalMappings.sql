CREATE VIEW [dbo].[vwMissingHospitalMappings]
AS

-- LTBR hospital is not in migration mapping
SELECT CONCAT(dp_PatientID, '-', dp_DiseasePeriod) AS OldNotificationId,
	'LTBR' AS [Source],
	dp_NotifiedDate AS NotificationDate,
	CAST(dp_NotifyingClinicID AS NVARCHAR(50)) AS HospitalId,
	lh_HospitalName COLLATE Latin1_General_CI_AS AS HospitalName,
	residencePhec.[Name] AS ResidenceRegion,
	CAST(NULL AS NVARCHAR) AS TreatmentRegion
FROM [$(migration)].dbo.LTBR_DiseasePeriod dp
	INNER JOIN [$(migration)].dbo.LtbrAddresses a ON a.OldNotificationId = CONCAT(dp_PatientID, '-', dp_DiseasePeriod)
	LEFT JOIN [$(LTBR)].dbo.sbt_LondonHospitals lh ON dp_NotifyingClinicID = lh_HospitalID
	LEFT JOIN [$(NTBS_R1_Geography_Staging)].dbo.Reduced_Postcode_file rpcd ON rpcd.Pcode = a.Postcode
	LEFT JOIN [$(NTBS_R1_Geography_Staging)].dbo.LA_to_PHEC residenceLA ON residenceLA.LA_Code = rpcd.LA_Code
	LEFT JOIN [$(NTBS)].ReferenceData.PHEC residencePhec ON residenceLA.PHEC_Code = residencePhec.Code
WHERE (dp_NotifyingClinicID IS NULL OR dp_NotifyingClinicID NOT IN (SELECT LtbrId FROM [$(migration)].dbo.LtbrHospitalsMapping))
	AND YEAR(dp_NotifiedDate) IN (SELECT NotificationYear FROM vwNotificationYear)

UNION

-- ETS/NTBS Hospital mapped to from LTBR hospital does not exist in NTBS
SELECT CONCAT(dp_PatientID, '-', dp_DiseasePeriod) AS OldNotificationId,
	'LTBR' AS [Source],
	dp_NotifiedDate AS NotificationDate,
	CAST(dp_NotifyingClinicID AS NVARCHAR(50)) AS HospitalId,
	lhm.LtbrName AS HospitalName,
	residencePhec.[Name] AS ResidenceRegion,
	CAST(NULL AS NVARCHAR) AS TreatmentRegion
FROM [$(migration)].dbo.LTBR_DiseasePeriod dp
	INNER JOIN [$(migration)].dbo.LtbrAddresses a ON a.OldNotificationId = CONCAT(dp_PatientID, '-', dp_DiseasePeriod)
	INNER JOIN [$(migration)].dbo.LtbrHospitalsMapping lhm ON dp_NotifyingClinicID = lhm.LtbrId
	LEFT JOIN [$(NTBS_R1_Geography_Staging)].dbo.Reduced_Postcode_file rpcd ON rpcd.Pcode = a.Postcode
	LEFT JOIN [$(NTBS_R1_Geography_Staging)].dbo.LA_to_PHEC residenceLA ON residenceLA.LA_Code = rpcd.LA_Code
	LEFT JOIN [$(NTBS)].ReferenceData.PHEC residencePhec ON residenceLA.PHEC_Code = residencePhec.Code
WHERE (lhm.NtbsId IS NULL OR lhm.NtbsId NOT IN (SELECT HospitalId FROM [$(NTBS)].ReferenceData.Hospital))
	AND YEAR(dp_NotifiedDate) IN (SELECT NotificationYear FROM vwNotificationYear)

UNION

-- ETS hospital is not in NTBS
SELECT CAST(n.LegacyId AS NVARCHAR(50)) AS OldNotificationId,
	'ETS' AS [Source],
	n.NotificationDate,
	CAST(n.HospitalId AS NVARCHAR(50)) AS HospitalId,
	h.[Name] AS HospitalName,
	residencePhec.[Name] AS ResidenceRegion,
	treatmentPhec.[Name] AS TreatmentRegion
FROM [$(migration)].dbo.ETS_Notification n
	INNER JOIN [$(migration)].dbo.EtsAddresses a ON n.LegacyId = a.OldNotificationId
	LEFT JOIN [$(OtherServer)].[$(ETS)].dbo.Hospital h ON n.HospitalId = h.Id
	LEFT JOIN [$(NTBS_R1_Geography_Staging)].dbo.Reduced_Postcode_file rpcd ON rpcd.Pcode = a.Postcode
	LEFT JOIN [$(NTBS_R1_Geography_Staging)].dbo.LA_to_PHEC residenceLA ON residenceLA.LA_Code = rpcd.LA_Code
	LEFT JOIN [$(NTBS)].ReferenceData.PHEC residencePhec ON residenceLA.PHEC_Code = residencePhec.Code
	LEFT JOIN vwEtsUserPermissionMembership caseManagerMemberships ON n.OwnerUserId = caseManagerMemberships.UserId
	LEFT JOIN [$(NTBS)].ReferenceData.PHEC AS treatmentPhec ON caseManagerMemberships.PhecCode = treatmentPhec.Code
WHERE n.HospitalId NOT IN (SELECT HospitalId FROM [$(NTBS)].ReferenceData.Hospital)
	AND n.LegacyId NOT IN (SELECT LegacyId FROM [$(migration)].dbo.EtsManuallyMappedHospitals)
	AND n.LegacyId NOT IN (SELECT LegacyId FROM [$(migration)].dbo.EtsManualOverrideHospitals)
	AND YEAR(n.NotificationDate) IN (SELECT NotificationYear FROM vwNotificationYear)
