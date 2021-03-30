/***************************************************************************************************
Desc:    This pre-calculates and pre-generates most reporting data.
         This job is scheduled to run over-night!


         
**************************************************************************************************/
CREATE PROCEDURE [dbo].[uspGenerate] AS
	SET NOCOUNT ON

	BEGIN TRY
		-- If any "Generate" procs errors, then roll back all "Generate" procs !
		BEGIN TRANSACTION

		-- Re-seed drop-downs (in case data has changed)
		EXEC dbo.uspSeed
		EXEC dbo.uspGenerateTB_Service

		-- Populate Reference Lab Result data
		EXEC dbo.uspLabSpecimen

		-- Populate manual lab result tables
		

		-- Populate reusable notification table
		EXEC dbo.uspGenerateReusableNotification_ETS
		EXEC dbo.uspGenerateReusableNotification

		-- Populate report-specific tables
		EXEC dbo.uspGenerateLegacyExtract
		EXEC dbo.uspGenerateLegacyLabDataExtract
		EXEC dbo.uspGenerateCultureResistance
		EXEC dbo.uspGenerateOutcomeSummary
		EXEC dbo.uspGenerateDataQuality

		-- Populate boilerplate report too (not much overhead, so might as well for demo purposes)

		-- Needs to be executed after any report requiring use of PostcodeLookup table
		EXEC dbo.uspUpdateReusableNotificationPostcode

		-- Save last refresh date to footer
		EXEC dbo.uspGenerateFooter

		COMMIT
	END TRY
	BEGIN CATCH
		-- A "Generate" proc has errored
		IF @@TRANCOUNT > 0  
			ROLLBACK TRANSACTION;  

		-- Show error on screen
		EXEC dbo.uspHandleException
	END CATCH
