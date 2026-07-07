CREATE VIEW [LTBI].[vwUserPermissions]
	AS  

	SELECT Username AS upn, COALESCE(i.ICBCodeH, A.[value]) AS 'Code'
	FROM [$(NTBS)].[dbo].[User]

		CROSS APPLY STRING_SPLIT(AdGroups, ',') A
		LEFT OUTER JOIN [$(NTBS)].[LTBIReferenceData].LookICBADGrp t ON t.ADGrpName = A.[value]
		LEFT OUTER JOIN [$(NTBS)].[LTBIReferenceData].LookICB i on i.ICBId = t.ICBId
		--LEFT OUTER JOIN [NTBS_LTBI_Test].[LTBIReferenceData].LookLabADGrp p ON p.ADGrpName = A.[value]
WHERE a.[value] not like '%NTBS%'