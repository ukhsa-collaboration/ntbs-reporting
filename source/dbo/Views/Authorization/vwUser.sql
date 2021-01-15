CREATE VIEW [dbo].[vwUser]
	AS 
	--TODO this should be replaced with a call to the User table in the Reporting database
	SELECT Username as upn, u.DisplayName 
	FROM [$(NTBS)].[dbo].[User] u