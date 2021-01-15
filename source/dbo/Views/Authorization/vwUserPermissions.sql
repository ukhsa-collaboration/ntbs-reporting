CREATE VIEW [dbo].[vwUserPermissions]
	AS 
	--create one row for each AD group the user is a member of
	--TODO: replace this with a call to the reporting user table
	SELECT Username AS upn, COALESCE(t.Code, p.Code, A.[value]) AS 'Code', COALESCE(t.[Name], p.[Name]) AS 'Name' 
	FROM [$(NTBS)].[dbo].[User]

		CROSS APPLY STRING_SPLIT(AdGroups, ',') A
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[TbService] t ON t.ServiceAdGroup = A.[value]
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[PHEC] p ON p.AdGroup = A.[value]

		WHERE 
		A.[value] != 'Global.NIS.NTBS.Admin'
		AND A.[value] != 'Global.NIS.NTBS.NTS'
		