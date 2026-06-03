
/***************************************************************************************************
Desc:    This seeds or re-seeds the look-up-data. It gets called from uspGenerate(),
		 so is run straight after every code deployment. If in doubt, you can also
		 run this proc stand-alone at any time, and it will re-seed the look-up data.



**************************************************************************************************/

CREATE PROCEDURE [LTBI].[uspSeed] AS
	BEGIN TRY
		-- If any errors, then roll back
		BEGIN TRANSACTION

 

		-- If the feature flags have not been set, set them
		-- These include or exclude records from various datasources in the reporting database
		IF NOT EXISTS (SELECT 1 FROM [dbo].[ReportingFeatureFlags])
		BEGIN
			INSERT INTO [dbo].[ReportingFeatureFlags](IncludeNTBS, IncludeETS, IncludeLabBase, Comment)
			VALUES(1, 1, 1, 'Include or exclude records from various datasources in the reporting database')
		END

	 

		-- Other inserts
		TRUNCATE TABLE [LTBI].[TemplateText]
		INSERT INTO [LTBI].[TemplateText]([Desc],[Text])
		VALUES
			('Footer text to be displayed in each report',
			' 1.1. The source LTBI data presented is correct as at {LTBI_LAST_REFRESHED}.  
			1.2 The data presented in this report was generated at {REPORTING_LAST_REFRESHED}.
			2. The data presented is provisional and is subject to change.
			3. Source: Reporting Service, National TB Surveillance system (NTBS). Use of data is covered by LTBI Data Access and Provision Policies
			Reporting version: Release-{REPORTING_RELEASE_VERSION}-{REPORTING_RELEASE_DATE}')
			 

		COMMIT
	END TRY
	BEGIN CATCH
		-- A "Generate" proc has errored
		ROLLBACK

		-- Show error on screen
		EXEC dbo.uspHandleException
	END CATCH