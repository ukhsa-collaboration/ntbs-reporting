/*
This is used to create a file of cases to migrate into NTBS

TODO: it needs to exclude all but one record within each group, otherwise NTBS will try and import the group twice and complain that the record already exists
It needs to include the LTBR ID (in the 1234-1 format) rather than the ETS Id if this is how NTBS is going to import the record, because there is an overlap
in very recent LTBR numbers and very old ETS Ids.  So to make sure we pick the right record, we need to differentiate the Ids

*/

CREATE PROCEDURE [dbo].[uspMigrationLineList]
	@Region VARCHAR(50)		=	NULL

AS
	SELECT EtsID 
	FROM [dbo].[MigrationMasterList] 
	WHERE Region = @Region
	AND [NotificationDate] >= '2017-01-01'
RETURN 0
