/*this will be used to confirm to regional staff which notifications will be included in their data migration.
It will include:
- all notified cases from 2017 which are being TREATED in the region
- all denotified cases from the last 18 months (as all other denotified cases are ignored anyway
- a note of any case which is linked to an LTBR case and which system will be used as the source
- any groups of records included
*/


CREATE PROCEDURE [dbo].[uspConfirmationLineList]
	@Region VARCHAR(50)		=	NULL

AS


	SELECT * FROM [dbo].[MigrationMasterList] 
	WHERE Region = @Region
	AND [NotificationDate] >= '2017-01-01'

	UNION
	-- we are using the de-duplication of 'UNION' here to avoid returning the records which are in both SELECT statements twice
	SELECT * FROM [dbo].[MigrationMasterList] WHERE GroupId IN
	(SELECT DISTINCT GroupId FROM [dbo].[MigrationMasterList] 
	WHERE Region = @Region
	AND [NotificationDate] >= '2017-01-01'
	AND GroupId IS NOT NULL)

	ORDER BY [NotificationDate] DESC
	
RETURN 0
