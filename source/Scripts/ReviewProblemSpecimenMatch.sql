
DECLARE @ReferenceLaboratoryNumber NVARCHAR(25) -- = set parameter value here

SELECT lm.*, s.ScenarioDescription
FROM [dbo].vwComparisonOfLabMatches lm
	LEFT OUTER JOIN [vwComparisonOfLabMatchScenarios] s ON s.Scenario = lm.Scenario
WHERE ReferenceLaboratoryNumber = @ReferenceLaboratoryNumber

SELECT 'SpecimenDetails' AS 'Info', SpecimenDate, EarliestRecordDate, LaboratoryName, PatientNhsNumber, PatientBirthDate, PatientName,
	PatientSex, PatientAddress, PatientPostcode
FROM [$(NTBS_Specimen_Matching)].[dbo].[LabSpecimen]
WHERE ReferenceLaboratoryNumber = @ReferenceLaboratoryNumber

 --then all NTBS matches, including any rejected ones

SELECT 'NTBS match' AS 'Info', nsm.NotificationId, MatchType, UpdateDateTime, ConfidenceLevel, MatchMethod,
 CASE WHEN le.Denotified = 'Yes' THEN 'Denotified' ELSE 'Notified' END AS NotificationStatus, rn.NotificationDate, rn.NhsNumber, rn.DateOfBirth,
	CONCAT(UPPER(rn.Surname), ', ', rn.Forename) AS PatientName,
	rn.Sex, le.AddressLine1, rn.Postcode
FROM [NTBS_Specimen_Matching].[dbo].[NotificationSpecimenMatch] nsm
	INNER JOIN [dbo].[ReusableNotification] rn ON rn.NtbsId = nsm.NotificationID
	LEFT OUTER JOIN [dbo].[LegacyExtract] le ON le.NtbsId = nsm.NotificationID
WHERE ReferenceLaboratoryNumber = @ReferenceLaboratoryNumber

--then the ETS record that the NTBS one(s) were migrated from

SELECT 'ETS details of migrated NTBS record' AS 'Info', ets.LegacyId,
	CASE
		WHEN ets.DenotificationId IS NOT NULL THEN 'Denotified'
		WHEN ets.AuditDelete IS NOT NULL THEN 'Deleted'
		WHEN ets.Submitted = 0 THEN 'Draft'
		ELSE 'Notified'
	END AS NotificationStatus
	, ets.NotificationDate, p.NhsNumber, p.DateOfBirth, CONCAT(UPPER(p.Surname), ', ', p.Forename) AS PatientName,
	p.Sex, CONCAT(a.Line1, a.Line2, a.freetextCityName, a.freetextCountyName) AS PatientAddress, pc.Pcd2
FROM [NTBS_Specimen_Matching].[dbo].[NotificationSpecimenMatch] nsm
	INNER JOIN ReusableNotification rn ON rn.NotificationId = nsm.NotificationID
	INNER JOIN [ets].[dbo].[Notification] ets ON ets.LegacyId = rn.ETSID
	INNER JOIN [ets].[dbo].[Patient] p ON p.Id = ets.PatientId
	INNER JOIN [ets].[dbo].[Address] a ON a.Id = ets.AddressId
	INNER JOIN [ets].[dbo].[Postcode] pc ON pc.Id = a.PostcodeId
WHERE ReferenceLaboratoryNumber = @ReferenceLaboratoryNumber


--ETS matches
SELECT 'ETS Match' AS Info, esm.LegacyId, EarliestMatchDate, Denotified, Draft, Automatched,
	CASE
		WHEN ets.DenotificationId IS NOT NULL THEN 'Denotified'
		WHEN ets.AuditDelete IS NOT NULL THEN 'Deleted'
		WHEN ets.Submitted = 0 THEN 'Draft'
		ELSE 'Notified'
	END AS NotificationStatus
	,ets.NotificationDate, p.NhsNumber, p.DateOfBirth, CONCAT(UPPER(p.Surname), ', ', p.Forename) AS PatientName,
	p.Sex, CONCAT(a.Line1, a.Line2, a.freetextCityName, a.freetextCountyName) AS PatientAddress, pc.Pcd2
FROM [$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch] esm
	INNER JOIN [ets].[dbo].[Notification] ets ON ets.LegacyId = esm.LegacyId
	INNER JOIN [ets].[dbo].[Patient] p ON p.Id = ets.PatientId
	INNER JOIN [ets].[dbo].[Address] a ON a.Id = ets.AddressId
	INNER JOIN [ets].[dbo].[Postcode] pc ON pc.Id = a.PostcodeId
WHERE ReferenceLaboratoryNumber = @ReferenceLaboratoryNumber

--shot in the dark matches that would not appear in EtsSpecimenMatch - this is where the match has been deleted or the notification has been deleted
 SELECT n.LegacyId,
	CASE WHEN n.AuditDelete IS NOT NULL THEN 'Notification deleted'
		WHEN lr.AuditDelete IS NOT NULL THEN 'Match deleted'
	END AS DeletionReason
 FROM [ets].[dbo].[LaboratoryResult] lr
	INNER JOIN [labbase2].[dbo].[Anonymised] a ON a.OpieId = lr.OpieId --AND lr.AuditDelete IS NULL
	INNER JOIN [ets].[dbo].[Notification] n ON n.Id = lr.NotificationId
 WHERE ReferenceLaboratoryNumber = @ReferenceLaboratoryNumber
 AND (n.AuditDelete IS NOT NULL OR lr.AuditDelete IS NOT NULL)
