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
		DECLARE @NtbsLastRefreshed AS DATETIME
		DECLARE @ReportingVersion AS VARCHAR(50)
		DECLARE @ReportingVersionDate AS DATETIME
		
		-- Get footer template text
		SET @FooterText = (SELECT Text
							FROM TemplateText)

		SET @NtbsLastRefreshed = (SELECT MAX([AuditDateTime])
			FROM [$(NTBS_AUDIT)].[dbo].[AuditLogs]
			WHERE AuditDateTime > DATEADD(DAY, -7, GETUTCDATE())
				AND RootEntity = 'Notification'
				AND EventType != 'Read')
		
		-- When were the generated reusable tables last refreshed ?
		Set @ReportingLastRefreshed = (select top 1 DataRefreshedAt from ReusableNotification n order by DataRefreshedAt desc)

		-- When was ETS last loaded ?
		Set @EtsLastRefreshed = (SELECT top 1 AuditAlter FROM [$(ETS)].[dbo].[Notification] order by AuditAlter desc)
		--This is not correct but is the best approximation that can be obtained.

		Set @ReportingVersionDate = (SELECT [Date] FROM ReleaseVersion)
		Set @ReportingVersion = (SELECT [Version] FROM ReleaseVersion)

		-- Fail gracefully
		IF (@ReportingLastRefreshed IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_LAST_REFRESHED}', dbo.ufnFormatDateConsistently(@ReportingLastRefreshed) + ' ' + FORMAT(@ReportingLastRefreshed, 'HH:mm'))
		ELSE 
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_LAST_REFRESHED}', '"UNKNOWN"')

		IF (@EtsLastRefreshed IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{ETS_LAST_REFRESHED}', dbo.ufnFormatDateConsistently(@EtsLastRefreshed) + ' ' + FORMAT(@EtsLastRefreshed, 'HH:mm'))
		ELSE 
			SET @FooterText = REPLACE(@FooterText, '{ETS_LAST_REFRESHED}', '"UNKNOWN"')

		IF (@NtbsLastRefreshed IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{NTBS_LAST_REFRESHED}', dbo.ufnFormatDateConsistently(@NtbsLastRefreshed) + ' ' + FORMAT(@NtbsLastRefreshed, 'HH:mm'))
		ELSE
			SET @FooterText = REPLACE(@FooterText, '{NTBS_LAST_REFRESHED}', '"UNKNOWN"')

		IF (@ReportingVersion IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_RELEASE_VERSION}', @ReportingVersion)
		ELSE
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_RELEASE_VERSION}', '"UNKNOWN"')

		IF (@ReportingVersion IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_RELEASE_DATE}', dbo.ufnFormatDateConsistently(@ReportingVersionDate))
		ELSE
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_RELEASE_DATE}', '"UNKNOWN"')

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