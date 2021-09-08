--this produces a list of codes (TB service, PHEC) that the user is associated with
--by way of their AD group membership. It excludes the national team (NTS) and the Admin group
--as the national team can view all records and the Admin group is not about record access

CREATE VIEW [dbo].[vwUserPermissions]
	AS 
	--create one row for each AD group the user is a member of
	SELECT Username AS upn, COALESCE(t.Code, p.Code, A.[value]) AS 'Code', COALESCE(p.Code, t.PHECCode) AS 'Region'
	FROM [$(NTBS)].[dbo].[User]

		CROSS APPLY STRING_SPLIT(AdGroups, ',') A
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[TbService] t ON t.ServiceAdGroup = A.[value]
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[PHEC] p ON p.AdGroup = A.[value]
		WHERE 
		A.[value] != 'Global.NIS.NTBS.Admin'
		AND A.[value] != 'Global.NIS.NTBS.NTS'
		