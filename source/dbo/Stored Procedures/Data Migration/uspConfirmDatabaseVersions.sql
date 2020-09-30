CREATE PROCEDURE [dbo].[uspConfirmDatabaseVersions]
	
AS

	WITH EtsDate AS
	(SELECT CONVERT(DATE, MAX(NotificationDate)) AS EtsDate FROM [$(ETS)].[dbo].[Notification]),
	LtbrDate AS
	(SELECT CONVERT(DATE, MAX(dp_NotifiedDate)) AS LtbrDate FROM [$(LTBR)].[dbo].[dbt_DiseasePeriod]),
	LabbaseDate AS
	(SELECT CONVERT(DATE, MAX(AuditCreate)) AS LabbaseDate FROM [$(Labbase2)].[dbo].[Anonymised])

	SELECT EtsDate, LtbrDate, LabbaseDate
		FROM EtsDate, LtbrDate, LabbaseDate
RETURN 0
