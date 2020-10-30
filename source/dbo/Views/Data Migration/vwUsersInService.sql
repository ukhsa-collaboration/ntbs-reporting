/*this view brings together contact details from the service directory
along with information pulled from ETS for users who do not appear in the service directory, primarily Yorkshire & Humber
*/


CREATE VIEW [dbo].[vwUsersInService]
AS
	SELECT DISTINCT
	CASE WHEN Email_address_1 LIKE '%phe.gov.uk' THEN Email_address_1
		WHEN Email_address_2 LIKE '%phe.gov.uk' THEN Email_address_2
		WHEN Email_address_1 LIKE '%nhs.net' THEN Email_address_1
		WHEN Email_address_2 LIKE '%nhs.net' THEN Email_address_2
		WHEN p.Email LIKE '%phe.gov.uk' THEN p.Email
		WHEN p.Email LIKE '%nhs.net'THEN p.Email
		ELSE NULL
		END AS username,

		COALESCE(c.Forename, p.Forename) AS givenname,
		COALESCE(c.Surname, p.Surname) AS familyname,
		COALESCE(c.Email_address_1, p.Email) AS email,
		c.Email_address_2 AS secondaryemail,
		c.Telephone_1 AS telephone1,
		c.Telephone_2 AS telephone2,
		c.Position,
		c.HPT_Note AS Notes,
		COALESCE(Q1.EtsAccounts, Q2.EtsAccounts) AS EtsAccounts,
		p.MembershipCode AS TB_Service_Code
	FROM  [dbo].[vwEtsUserPermissionMembership] p
	LEFT OUTER JOIN [dbo].[vwServiceDirUserToEtsUser] e on e.ETS_username = p.Username
	LEFT OUTER JOIN [dbo].[vwServiceDirContactDetails] c ON c.UniqueId = e.UniqueId
	LEFT OUTER JOIN 
		(SELECT UniqueId, STRING_AGG([ETS_username], ', ') AS EtsAccounts FROM 
		[dbo].[vwServiceDirUserToEtsUser] GROUP BY UniqueId) AS Q1 ON Q1.UniqueId = c.UniqueId
	LEFT OUTER JOIN 
		(SELECT UniqueId, STRING_AGG([ETS_username], ', ') AS EtsAccounts FROM 
		[dbo].[vwServiceDirUserToEtsUser] GROUP BY UniqueId) AS Q2 ON Q2.UniqueId = CONCAT([dbo].ufnStripNonAlphaChars(p.Forename), [dbo].ufnStripNonAlphaChars(p.Surname))
WHERE p.UserType = 'Service'

