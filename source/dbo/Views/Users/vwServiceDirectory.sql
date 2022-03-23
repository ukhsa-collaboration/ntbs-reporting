CREATE VIEW [dbo].[vwServiceDirectory]
	AS
	SELECT 
		p.Code AS RegionCode,
		p.Name AS Region,
		tbs.Code AS TbServiceCode,
		tbs.Name AS TbServiceName,
		[DisplayName]
		,[Notes]
		,COALESCE([EmailPrimary], u.[Username]) AS EmailAddress
		,[EmailSecondary]
		,[JobTitle]
		,[PhoneNumberPrimary]
		,[PhoneNumberSecondary]
		,Q1.LastLoggedIn
	FROM [$(NTBS)].[dbo].[User] u
		INNER JOIN [dbo].[vwUserPermissions] up ON up.upn = u.Username
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[TbService] tbs ON tbs.Code = up.Code
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[PHEC] p ON p.Code = up.Region
		LEFT OUTER JOIN 
			(SELECT 
				Username, 
				MAX(LoginDate) AS LastLoggedIn 
			FROM [$(NTBS)].[dbo].[UserLoginEvent]
			GROUP BY Username) AS Q1 ON Q1.Username = u.Username
	WHERE IsActive = 1 AND up.Region IS NOT NULL and u.Username NOT LIKE '%softwire.com%'