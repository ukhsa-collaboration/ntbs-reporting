CREATE PROCEDURE [dbo].[uspConfirmDatabaseVersions]
	(@MigrationRun INT = NULL)
	
AS

	SELECT EtsDate, LabbaseDate, LtbrDate, AppVersion FROM
		[dbo].[MigrationRun]
	WHERE MigrationRunId = @MigrationRun
RETURN 0
