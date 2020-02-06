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
		Set @ReportingLastRefreshed = (select top 1 DataRefreshedAt from ReusableNotification n order by DataRefreshedAt desc)

		-- When was ETS last loaded ?
		Set @EtsLastRefreshed = (SELECT top 1 AuditAlter FROM [$(ETS)].[dbo].[Notification] order by AuditAlter desc)
		--This is not correct but is the best approximation that can be obtained.

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