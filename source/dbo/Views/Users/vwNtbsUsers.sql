CREATE VIEW [dbo].[vwNtbsUsers]
AS

	SELECT *
	FROM [$(NTBS)].[dbo].[User]
