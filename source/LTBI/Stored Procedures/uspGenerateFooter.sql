/***************************************************************************************************
Desc:    This pre-calculates over-night the footer text that gets displayed underneath every SSRS report
         (derived from some template text).


         
**************************************************************************************************/

CREATE PROCEDURE [LTBI].[uspGenerateFooter] AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE @FooterText AS VARCHAR(1000)
		DECLARE @ReportingLastRefreshed AS DATETIME
	--	DECLARE @EtsLastRefreshed AS DATETIME
		DECLARE @LTBILastRefreshed AS DATETIME
		--DECLARE @ClusterLastRefreshed AS DATETIME
		DECLARE @ReportingVersion AS VARCHAR(50)
		DECLARE @ReportingVersionDate AS DATETIME
		
		-- Get footer template text
		SET @FooterText = (SELECT Text
							FROM [LTBI].[TemplateText])

		SET @LTBILastRefreshed = (SELECT MAX([AuditDateTime])
			FROM [$(NTBS_Audit)].[dbo].[AuditLogs]
			WHERE AuditDateTime > DATEADD(DAY, -7, GETUTCDATE())
				AND EntityType = 'LTBIPatient'
				AND EventType != 'Read')

		-- When Cluster information was last extracted (based on last backlog release)
	--	SET @ClusterLastRefreshed = (SELECT TOP 1 LastExtractionDate FROM [$(NTBS_Specimen_Matching)].[dbo].ForestClusterBuild)
		
		-- When were the generated reusable tables last refreshed ?
		Set @ReportingLastRefreshed = (select top 1 DataRefreshedAt from LTBI.LTBIBulkUploadTestingandTreatment n order by DataRefreshedAt desc)


		Set @ReportingVersionDate = (SELECT [Date] FROM ReleaseVersion)
		Set @ReportingVersion = (SELECT [Version] FROM ReleaseVersion)

		-- Fail gracefully
		IF (@ReportingLastRefreshed IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_LAST_REFRESHED}', dbo.ufnFormatDateConsistently(@ReportingLastRefreshed) + ' ' + FORMAT(@ReportingLastRefreshed, 'HH:mm'))
		ELSE 
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_LAST_REFRESHED}', '"UNKNOWN"')

		 

		IF (@LTBILastRefreshed IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{LTBI_LAST_REFRESHED}', dbo.ufnFormatDateConsistently(@LTBILastRefreshed) + ' ' + FORMAT(@LTBILastRefreshed, 'HH:mm'))
		ELSE
			SET @FooterText = REPLACE(@FooterText, '{LTBI_LAST_REFRESHED}', '"UNKNOWN"')

		

		IF (@ReportingVersion IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_RELEASE_VERSION}', @ReportingVersion)
		ELSE
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_RELEASE_VERSION}', '"UNKNOWN"')

		IF (@ReportingVersion IS NOT NULL)
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_RELEASE_DATE}', dbo.ufnFormatDateConsistently(@ReportingVersionDate))
		ELSE
			SET @FooterText = REPLACE(@FooterText, '{REPORTING_RELEASE_DATE}', '"UNKNOWN"')

		DELETE FROM [LTBI].[FooterText]

		INSERT INTO [LTBI].[FooterText] (
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