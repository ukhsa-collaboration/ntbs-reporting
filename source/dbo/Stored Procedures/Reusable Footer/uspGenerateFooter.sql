/***************************************************************************************************
Desc:    This pre-calculates over-night the footer text that gets displayed underneath every SSRS report
         (derived from some template text).


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateFooter] AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE @FooterText AS VARCHAR(1000)
		DECLARE @ReportingLastRefreshed AS DATETIME
		DECLARE @EtsLastRefreshed AS DATETIME
		
		-- Get footer template text
		SET @FooterText = (SELECT Text
							FROM TemplateText)
		
		-- When were the generated reusable tables last refreshed ?
		SET @ReportingLastRefreshed = (SELECT TOP 1
										--us.database_id,
										--t.name,
										us.last_user_update AS last_refresh_datetime
									  FROM [$(DatabaseName)].sys.dm_db_index_usage_stats us
										INNER JOIN [$(DatabaseName)].sys.tables t ON t.object_id = us.object_id
									  WHERE us.last_user_update IS NOT NULL
										AND us.database_id = DB_ID('$(DatabaseName)')
										AND t.[name] LIKE 'Reusable%'
									  ORDER BY last_refresh_datetime)

		-- When was ETS last loaded ?
		SET @EtsLastRefreshed = (SELECT TOP 1
									restore_date AS last_refresh_datetime
								FROM msdb.dbo.restorehistory 
								WHERE destination_database_name = '$(ETS)'
								ORDER BY last_refresh_datetime DESC)

		-- Fail gracefully
		IF (@ReportingLastRefreshed IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_LAST_REFRESHED}', dbo.ufnFormatDateConsistently(@ReportingLastRefreshed) + ' ' + FORMAT(@ReportingLastRefreshed, 'HH:mm'))
		ELSE 
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_LAST_REFRESHED}', '"UNKNOWN"')

		IF (@EtsLastRefreshed IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{ETS_LAST_REFRESHED}', dbo.ufnFormatDateConsistently(@EtsLastRefreshed) + ' ' + FORMAT(@EtsLastRefreshed, 'HH:mm'))
		ELSE 
			SET @FooterText = REPLACE(@FooterText, '{ETS_LAST_REFRESHED}', '"UNKNOWN"')

		DELETE FROM [dbo].[FooterText]

		INSERT INTO [dbo].[FooterText] (
			FooterTextId,
			FooterText
		) VALUES (
			1,
			@FooterText
		)
	END TRY

	BEGIN CATCH
		THROW
	END CATCH