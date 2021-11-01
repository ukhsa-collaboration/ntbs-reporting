CREATE VIEW [dbo].[vwCaseManagerIssuesReport]
AS
WITH PermissionAliases(ETSName, AliasName) AS (
	SELECT 'BARNSLEY DISTRICT GENERAL HOSPITAL', 'BARNSLEY HOSPITAL'

	UNION

	SELECT 'Yorkshire and The Humber', 'Yorkshire and Humber'

	UNION

	--the 'HPA' permission doesn't have square brackets around it, so the substring performed below only leaves the 'P'
	SELECT 'P', 'National Team'

	UNION

	SELECT 'QUEEN ELIZABETH II HOSPITAL','QUEEN ELIZABETH HOSPITAL [KING''S LYNN]'
),

--get the permissions, map HPU up to Region and remove the first and last characters as these are (except for HPA) always square brackets
ETSPermissions AS (
	SELECT s.Id,
		LOWER(s.Username) AS Username,
		LOWER(s.Email) AS Email,
		[dbo].[ufnStripNonAlphaChars](s.Surname) AS Surname,
		s.Forename,
		s.AuditSuspended,
		CASE WHEN eth.Tier = 3 THEN SUBSTRING(eth2.[NAME], 2, LEN(eth2.[NAME])-2)
			ELSE SUBSTRING(eth.[NAME], 2, LEN(eth.[NAME])-2)
		END AS PermissionName,
		CASE
			WHEN s.PermissionId IS NULL THEN 'PermissionIdMissing'
			WHEN eth.Tier = 4 THEN 'Service'
			WHEN eth.Tier = 1 THEN 'National'
			ELSE 'Regional'
		END AS UserType
	FROM [$(OtherServer)].[$(ETS)].[dbo].[SystemUser] s
		LEFT OUTER JOIN [$(migration)].[dbo].[EtsLocationHierarchy] eth ON eth.Id = s.PermissionId
		LEFT OUTER JOIN [$(migration)].[dbo].[EtsLocationHierarchy] eth2 ON eth2.Id = eth.ParentId
	WHERE s.AuditDelete IS NULL
),
--overwrite the permission name
AliasedPermissions AS (
	SELECT ep.Id,
		ep.Username,
		ep.Email,
		ep.Surname,
		ep.Forename,
		ep.AuditSuspended,
		COALESCE(pa.AliasName, PermissionName) AS PermissionName,
		ep.UserType
	FROM ETSPermissions ep
		LEFT OUTER JOIN PermissionAliases pa ON pa.ETSName = ep.PermissionName
),
EtsUserDetails AS (
	SELECT ap.Id,
		ap.Username,
		ap.Email,
		ap.PermissionName,
		ap.UserType,
		ap.AuditSuspended,
		tbs.TB_Service_Code AS UserTbServiceCode,
		COALESCE(tbs.TB_Service_Code, p.PHEC_Code) AS MembershipCode,
		COALESCE(tbs.TB_Service_Name, p.PHEC_Name) AS Membership,
		rphec.Name AS TBServicePHEC
	FROM AliasedPermissions ap
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h ON h.HospitalName = ap.PermissionName
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = h.HospitalId
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs ON tbs.TB_Service_Code = tbh.TB_Service_Code
		LEFT OUTER JOIN [$(NTBS)].ReferenceData.TbService rtbs ON rtbs.Code = tbs.TB_Service_Code
		LEFT OUTER JOIN [$(NTBS)].ReferenceData.PHEC rphec ON rphec.Code = rtbs.PHECCode
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Name = ap.PermissionName
)
SELECT n.NotificationId,
	n.ETSID,
	n.NotificationDate,
	n.NotificationStatus,
	h.[Name] AS HospitalName,
	tbs.[Name] AS HospitalTbService,
	PHEC.[Name] AS HospitalPhec,
	u.IsCaseManager AS IsNtbsCaseManager,
	u.IsActive AS IsActiveInNtbs,
	CASE WHEN cmtbs.CaseManagerId IS NULL THEN 1 ELSE 0 END AS HospitalCaseManagerTbServiceMismatch,
	EtsUserDetails.[Username] AS EtsUsername,
	EtsUserDetails.[Email] AS EtsEmail,
	EtsUserDetails.AuditSuspended AS EtsSuspendedDate,
	EtsUserDetails.UserType AS EtsUserPermissionType,
	EtsUserDetails.PermissionName AS EtsUserPermissionName,
	EtsUserDetails.Membership AS EtsUserPermissionMembership,
	EtsUserDetails.TBServicePHEC AS EtsUserPermissionTbServicePhec,
	EtsUserDetails.MembershipCode AS EtsUserPermissionMembershipCode,
	EtsUserDetails.Id AS EtsUserId
FROM [$(NTBS)].dbo.[Notification] n
	INNER JOIN [$(NTBS)].dbo.HospitalDetails hd ON n.NotificationId = hd.NotificationId
	INNER JOIN [$(NTBS)].dbo.[User] u ON hd.CaseManagerId = u.Id
	INNER JOIN [$(NTBS)].ReferenceData.Hospital h ON hd.HospitalId = h.HospitalId
	INNER JOIN [$(NTBS)].ReferenceData.TbService tbs ON h.TBServiceCode = tbs.Code
	LEFT OUTER JOIN [$(NTBS)].ReferenceData.PHEC ON tbs.PHECCode = phec.Code

	LEFT JOIN [$(NTBS)].dbo.CaseManagerTbService cmtbs ON cmtbs.CaseManagerId = u.Id AND cmtbs.TbServiceCode = tbs.[Code]

	INNER JOIN [$(OtherServer)].[$(ETS)].dbo.[Notification] en ON en.LegacyId = n.ETSID
	LEFT OUTER JOIN [$(OtherServer)].[$(ETS)].dbo.SystemUser su ON su.Id = en.OwnerUserId
	LEFT OUTER JOIN EtsUserDetails ON EtsUserDetails.Id = su.Id
