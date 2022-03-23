CREATE VIEW [dbo].[vwUnmatchedDuplicates]
AS

-- NTBS Notifications, with all notifications migrated in from ETS
WITH NtbsNotifications AS (
	SELECT n.NotificationId AS NtbsId,
		CAST(n.ETSID AS INT) AS EtsId,
		'NTBS' AS SourceSystem,
		n.GroupId AS NtbsGroupId,
		etsGroupings.GroupId AS EtsGroupId,
		n.NotificationDate,
		n.CreationDate,
		COALESCE(cd.TreatmentStartDate, cd.DiagnosisDate, n.NotificationDate) AS TreatmentStartDate,
		p.Dob,
		CONCAT_WS(', ', UPPER(p.FamilyName), p.GivenName) AS FullName,
		COALESCE(tbs.[Name], h.[Name]) AS TbServiceName,
		phec.[Name] AS PhecName,
		REPLACE(STUFF(p.NhsNumber, 1, PATINDEX('%[0-9]%', p.NhsNumber)-1, ''),' ','') AS NhsNumber,
		COALESCE(u.EmailPrimary, u.Username) AS CaseManager
	FROM [$(NTBS)].dbo.[Notification] n
		INNER JOIN [$(NTBS)].dbo.Patients p ON n.NotificationId = p.NotificationId
		INNER JOIN [$(NTBS)].dbo.ClinicalDetails cd ON n.NotificationId = cd.NotificationId
		INNER JOIN [$(NTBS)].dbo.HospitalDetails hd ON n.NotificationId = hd.NotificationId
		LEFT JOIN [$(NTBS)].ReferenceData.Hospital h ON hd.HospitalId = h.HospitalId
		LEFT JOIN [$(NTBS)].ReferenceData.TbService tbs ON h.TBServiceCode = tbs.Code
		LEFT JOIN [$(NTBS)].ReferenceData.PHEC ON tbs.PHECCode = PHEC.Code
		LEFT JOIN [$(NTBS)].dbo.[User] u ON hd.CaseManagerId = u.Id
		LEFT JOIN [$(migration)].dbo.EtsGroupings etsGroupings ON n.ETSID = etsGroupings.EtsId
	WHERE n.NotificationStatus IN ('Notified', 'Closed')
),
NtbsLastRecordTreatmentOutcomeDates AS (
	SELECT n.NtbsId,
		MAX(te.EventDate) AS LastRecordedTreatmentOutcomeDate
	FROM [$(NTBS)].dbo.TreatmentEvent te
		INNER JOIN NtbsNotifications n ON te.NotificationId = n.NtbsId
	WHERE te.TreatmentEventType = 'TreatmentOutcome'
	GROUP BY n.NtbsId
),
-- ETS notifications that have not been migrated into NTBS
EtsNotifications AS (
	SELECT NULL AS NtbsId,
		n.LegacyId AS EtsId,
		'ETS' AS SourceSystem,
		NULL AS NtbsGroupId,
		etsGroupings.GroupId AS EtsGroupId,
		n.NotificationDate,
		n.AuditCreate AS CreationDate,
		COALESCE(te.StartOfTreatment, te.DateOfDiagnosis, n.NotificationDate) AS TreatmentStartDate,
		p.DateOfBirth,
		CONCAT_WS(', ', UPPER(p.Surname), p.Forename) AS FullName,
		COALESCE(tbs.[Name], h.[Name]) AS TbServiceName,
		phec.[Name] AS PhecName,
		REPLACE(STUFF(p.NhsNumber, 1, PATINDEX('%[0-9]%', p.NhsNumber)-1, ''),' ','') AS NhsNumber,
		COALESCE(su.Email, su.Username) AS CaseManager
	FROM [$(ETS)].dbo.[Notification] n
		INNER JOIN [$(ETS)].dbo.Patient p ON n.PatientId = p.Id
		LEFT JOIN [$(ETS)].dbo.TuberculosisEpisode te ON n.TuberculosisEpisodeId = te.Id
		LEFT JOIN [$(ETS)].dbo.SystemUser su ON n.OwnerUserId = su.Id
		LEFT JOIN [$(NTBS)].dbo.[Notification] ntbsNotification ON n.LegacyId = ntbsNotification.ETSID
		LEFT JOIN [$(NTBS)].ReferenceData.Hospital h ON n.HospitalId = h.HospitalId
		LEFT JOIN [$(NTBS)].ReferenceData.TbService tbs ON h.TBServiceCode = tbs.Code
		LEFT JOIN [$(NTBS)].ReferenceData.PHEC ON tbs.PHECCode = PHEC.Code
		LEFT JOIN [$(migration)].dbo.EtsGroupings etsGroupings ON n.LegacyId = etsGroupings.EtsId
	WHERE n.AuditDelete IS NULL AND n.Submitted = 1 AND n.DenotificationId IS NULL
		AND ntbsNotification.NotificationId IS NULL -- ie no corresponding NTBS migrated notification
),
EtsLastRecordTreatmentOutcomeDates AS (
	SELECT n.EtsId,
		MAX(mto.OutcomeDate) AS LastRecordedTreatmentOutcomeDate
	FROM [$(migration)].dbo.TreatmentOutcomes mto
		INNER JOIN EtsNotifications n ON mto.OldNotificationId = CAST(n.EtsId AS NVARCHAR)
	GROUP BY n.EtsId
),
AllNotifications AS (
	SELECT en.*, treatmentOutcomeDates.LastRecordedTreatmentOutcomeDate
	FROM EtsNotifications en
		LEFT JOIN EtsLastRecordTreatmentOutcomeDates treatmentOutcomeDates
		ON en.EtsId = treatmentOutcomeDates.EtsId

	UNION

	SELECT nn.*, treatmentOutcomeDates.LastRecordedTreatmentOutcomeDate
	FROM NtbsNotifications nn
		LEFT JOIN NtbsLastRecordTreatmentOutcomeDates treatmentOutcomeDates
		ON nn.NtbsId = treatmentOutcomeDates.NtbsId

)
SELECT an2.DateOfBirth AS DateOfBirth,
	an1.NhsNumber AS NhsNumber,
	an1.NtbsId AS NtbsId1,
	an1.ETSID AS EtsId1,
	an1.SourceSystem AS SourceSystem1,
	an1.NtbsGroupId AS NtbsGroupId1,
	an1.NtbsGroupId AS EtsGroupId1,
	an1.NotificationDate AS NotificationDate1,
	an1.CreationDate AS CreationDate1,
	an1.TreatmentStartDate AS TreatmentStartDate1,
	an1.LastRecordedTreatmentOutcomeDate AS LastRecordedTreatmentOutcomeDate1,
	an1.FullName AS FullName1,
	an1.TbServiceName AS TbServiceName1,
	an1.PhecName AS PhecName1,
	an1.CaseManager AS CaseManager1,
	an2.NtbsId AS NtbsId2,
	an2.ETSID AS EtsId2,
	an2.SourceSystem AS SourceSystem2,
	an2.NtbsGroupId AS NtbsGroupId2,
	an2.NtbsGroupId AS EtsGroupId2,
	an2.NotificationDate AS NotificationDate2,
	an2.TreatmentStartDate AS TreatmentStartDate2,
	an2.LastRecordedTreatmentOutcomeDate AS LastRecordedTreatmentOutcomeDate2,
	an2.CreationDate AS CreationDate2,
	an2.FullName AS FullName2,
	an2.TbServiceName AS TbServiceName2,
	an2.PhecName AS PhecName2,
	an2.CaseManager AS CaseManager2
FROM AllNotifications an1
	INNER JOIN AllNotifications an2
		-- Notifications duplicate NHS numbers and dates of birth
		ON an1.DateOfBirth = an2.DateOfBirth
		AND an1.NhsNumber = an2.NhsNumber
		-- But not the same notification twice
		AND (an1.NtbsId IS NULL OR an2.NtbsId IS NULL OR an1.NtbsId <> an2.NtbsId)
		AND (an1.EtsId IS NULL OR an2.EtsId IS NULL OR an1.EtsId <> an2.EtsId)
		-- Which are not grouped together in ETS or NTBS
		AND (an1.NtbsGroupId IS NULL OR an2.NtbsGroupId IS NULL OR an1.NtbsGroupId <> an2.NtbsGroupId)
		AND (an1.EtsGroupId IS NULL OR an2.EtsGroupId IS NULL OR an1.EtsGroupId <> an2.EtsGroupId)
		-- Deduplicate our output (so we don't get two records saying 1 matches 2, and 2 matches 1)
		AND (COALESCE(an1.NtbsId, an1.EtsId) > COALESCE(an2.NtbsId, an2.EtsId))
