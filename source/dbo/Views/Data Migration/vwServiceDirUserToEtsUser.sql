/*This should link all user IDs to a single identifier representing a person in the service directory.
The only thing we have to go on is firstname+surname so a composite ID is created from these*/

CREATE VIEW [dbo].[vwServiceDirUserToEtsUser]
	AS 
SELECT DISTINCT ETS_username, (CONCAT([dbo].ufnStripNonAlphaChars(Forename), [dbo].[ufnStripNonAlphaChars](Surname))) AS UniqueId
FROM [dbo].[ServiceDirectoryRawData]