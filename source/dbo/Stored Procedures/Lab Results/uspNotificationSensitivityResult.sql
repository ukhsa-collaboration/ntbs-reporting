CREATE PROCEDURE [dbo].[uspNotificationSensitivityResult]
	@Antibiotic nvarchar(5) = NULL
AS
	
	BEGIN TRY
		SET NOCOUNT ON
		
			DECLARE @Sql NVARCHAR(2000)

			--DEBUGGING
			--SET @Antibiotic = 'RIF'


			--first update the records which do have a result to the result with the lowest ranking - this indicates the highest severity
			SET @Sql = 'UPDATE [dbo].CultureAndResistanceSummary SET '
			 + @Antibiotic + ' = Q2.ResultOutputName FROM
				(SELECT Q1.NotificationID, vrm.ResultOutputName FROM
				(SELECT DISTINCT vcm.[NotificationID], MIN(vrm.[Rank]) AS ''MinRank''
					FROM [dbo].[vwConfirmedMatch] vcm
					INNER JOIN [dbo].vwResultMapping vrm on vrm.ResultOutputName = ' + @Antibiotic + '
					GROUP BY vcm.[NotificationID]) AS Q1
				INNER JOIN [dbo].vwResultMapping vrm on vrm.[Rank] = Q1.MinRank) AS Q2 
			WHERE Q2.NotificationID = [dbo].CultureAndResistanceSummary.NotificationId'

			PRINT @Sql
			EXEC sp_executesql @Sql
	

		
	
			--TODO: what to do for notifications with no matching lab results

END TRY
BEGIN CATCH
	THROW
END CATCH
