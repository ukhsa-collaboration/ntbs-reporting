/*this looks as the user permission hierarchy in ETS, performs a couple of substitutions
and then maps them to PHECs and TB services for presentation in the 'document 1' document
to end users to confirm prior to migrating to the new system*/

CREATE VIEW [dbo].[vwEtsUserPermissionMembership]
	AS 
	
--create some aliases where the names in ETS are out of date
WITH PermissionAliases(ETSName, AliasName) AS
(SELECT 'BARNSLEY DISTRICT GENERAL HOSPITAL', 'BARNSLEY HOSPITAL'
UNION
SELECT 'Yorkshire and The Humber', 'Yorkshire and Humber'
UNION
--the 'HPA' permission doesn't have square brackets around it, so the substring performed below only leaves the 'P'
SELECT 'P', 'National Team'
UNION
SELECT 'QUEEN ELIZABETH II HOSPITAL','QUEEN ELIZABETH HOSPITAL [KING''S LYNN]'),

--get the permissions, map HPU up to Region and remove the first and last characters as these are (except for HPA) always square brackets
ETSPermissions AS
(SELECT LOWER(s.Username) AS Username, LOWER(s.Email) AS Email, s.Surname, s.Forename, 
	CASE WHEN eth.Tier = 3 THEN  SUBSTRING(eth2.[Name], 2, LEN(eth2.[Name])-2) 
	ELSE SUBSTRING(eth.[NAME], 2, LEN(eth.[NAME])-2) END AS PermissionName,  
 CASE 
	WHEN eth.Tier = 4 THEN 'Service' 
	WHEN eth.Tier = 1 THEN 'National'
	ELSE 'Regional' END AS UserType FROM [$(ETS)].[dbo].[SystemUser] s 
  INNER JOIN [$(migration)].[dbo].[EtsLocationHierarchy] eth ON eth.Id = s.PermissionId 
  LEFT OUTER JOIN [$(migration)].[dbo].[EtsLocationHierarchy] eth2 ON eth2.Id = eth.ParentId
WHERE s.AuditDelete IS NULL AND AuditSuspended IS NULL),
--overwrite the permission name
AliasedPermissions AS
(
 SELECT ep.Username, ep.Email, ep.Surname, ep.Forename,
 COALESCE(pa.AliasName, PermissionName) AS PermissionName, ep.UserType FROM ETSPermissions ep
	LEFT OUTER JOIN PermissionAliases pa ON pa.ETSName = ep.PermissionName
)


SELECT ap.Username, ap.Email, ap.Surname, ap.Forename, ap.PermissionName, ap.UserType, COALESCE(tbs.TB_Service_Code, p.PHEC_Code) AS 'MembershipCode', COALESCE(tbs.TB_Service_Name, p.PHEC_Name) AS 'Membership'
FROM
AliasedPermissions ap
 
LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h ON h.HospitalName = ap.PermissionName
LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = h.HospitalId
LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs ON tbs.TB_Service_Code = tbh.TB_Service_Code
LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] p ON p.PHEC_Name = ap.PermissionName
WHERE UserType = 'National' OR COALESCE(tbs.TB_Service_Name, p.PHEC_Name) IS NOT NULL
