/*This should link all user IDs to a single identifier representing a person.
It looks for the person first in the service directory and then in ETS, which in most cases
will ensure that a single unique ID is created for the person (if the user is not in the directory
and has multiple ETS accounts and has updated the surname on them to include something other than
numbers this won't work, but is close enough.
The only thing we have to go on is firstname+surname so a composite ID is created from these*/

CREATE VIEW [dbo].[vwServiceDirUserToEtsUser]
	AS 
SELECT Q1.ETS_username, CONCAT([dbo].ufnStripNonAlphaChars(COALESCE(rd.Forename, su2.Forename)), [dbo].ufnStripNonAlphaChars(COALESCE(rd.Surname, su2.Surname))) AS UniqueId
FROM
(
SELECT DISTINCT ETS_username
FROM [dbo].[ServiceDirectoryRawData]
UNION
SELECT DISTINCT username
FROM [$(ETS)].[dbo].[SystemUser] su WHERE su.AuditDelete IS NULL and su.AuditSuspended IS NULL
) AS Q1 LEFT OUTER JOIN [dbo].[ServiceDirectoryRawData] rd ON rd.ETS_username = Q1.ETS_username
LEFT OUTER JOIN [$(ETS)].[dbo].[SystemUser] su2 ON su2.Username = Q1.ETS_username