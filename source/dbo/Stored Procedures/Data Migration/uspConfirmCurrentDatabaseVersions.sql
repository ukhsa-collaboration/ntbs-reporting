CREATE PROCEDURE [dbo].[uspConfirmCurrentDatabaseVersions]
	
AS

	--this should also confirm when the migration database was last regenerated, but the field doesn't exist yet
	
	WITH EtsDate AS
	(SELECT CONVERT(DATE, MAX(NotificationDate)) AS EtsDate FROM [$(ETS)].[dbo].[Notification]),
	LtbrDate AS
	(SELECT CONVERT(DATE, MAX(dp_NotifiedDate)) AS LtbrDate FROM [$(LTBR)].[dbo].[dbt_DiseasePeriod]),
	LabbaseDate AS
	(SELECT CONVERT(DATE, MAX(AuditCreate)) AS LabbaseDate FROM [$(Labbase2)].[dbo].[Anonymised]),
	MigrationDate AS
	(SELECT LastRunDate FROM [$(migration)].[dbo].[MigrationInfo])

	SELECT EtsDate, LtbrDate, LabbaseDate, LastRunDate AS 'MigrationDate'
		FROM EtsDate, LtbrDate, LabbaseDate, MigrationDate
RETURN 0
