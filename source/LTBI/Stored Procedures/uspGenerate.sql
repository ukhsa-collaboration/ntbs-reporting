/***************************************************************************************************
Desc:    This pre-calculates and pre-generates most reporting data.
         This job is scheduled to run over-night!



**************************************************************************************************/
CREATE PROCEDURE [LTBI].[uspGenerate] AS
	SET NOCOUNT ON

	BEGIN TRY
		-- If any "Generate" procs errors, then roll back all "Generate" procs !
		BEGIN TRANSACTION

		EXEC [LTBI].[uspSeed]

		EXEC LTBI.uspGenerateTestingandTreatment
		 
		-- Save last refresh date to footer
		EXEC LTBI.uspGenerateFooter 

		COMMIT
	END TRY
	BEGIN CATCH
		-- A "Generate" proc has errored
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;

		-- Show error on screen
		EXEC dbo.uspHandleException
	END CATCH
