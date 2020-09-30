CREATE PROCEDURE [dbo].[uspMigrationLineList]
	@Region VARCHAR(50)		=	NULL

AS
	SELECT EtsID 
	FROM [dbo].[MigrationMasterList] 
	WHERE Region = @Region
	AND [NotificationDate] >= '2017-01-01'
RETURN 0
