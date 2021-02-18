CREATE PROCEDURE [dbo].[uspMigrationAlertSummary]
	@MigrationRun INT = NULL
AS
SELECT AlertType
,Count(*) AS 'Count' 
FROM MigrationAlert 
WHERE MigrationRunId = @MigrationRun
GROUP BY AlertType
ORDER BY AlertType