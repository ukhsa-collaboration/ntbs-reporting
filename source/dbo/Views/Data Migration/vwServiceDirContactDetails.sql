/*This creates a composite view of contact information for each person in the service directory.
We have to rely on firstname + surname to identify a person uniquely, and exclude some additional rows which do not have new information
in them. The use of 'Max' compresses multiple rows where, for example, one has a telephone number 2 and the other does not for the same person*/

CREATE VIEW [dbo].[vwServiceDirContactDetails]
	AS 

SELECT DISTINCT UniqueId, Forename, Surname, Email_address_1, MAX(Email_address_2) AS Email_address_2, MAX(Position) AS Position, MAX(Telephone_1) AS Telephone_1, 
	MAX(Telephone_2) AS Telephone_2, MAX(HPT_Note) AS HPT_Note
FROM
(SELECT  (CONCAT([dbo].ufnStripNonAlphaChars(Forename),
	[dbo].[ufnStripNonAlphaChars](Surname))) AS UniqueId, Forename, Surname, Email_address_1, Email_address_2, Position, Telephone_1, Telephone_2, HPT_Note 
	FROM [dbo].[ServiceDirectoryRawData]
	WHERE Email_address_1 NOT IN ('jonathanmyers@nhs.net', 'tracy.magnall@mft.nhs.uk', 'emma.gluba@wsht.nhs.uk')) AS Q1

GROUP BY UniqueId, Forename, Surname, Email_address_1
