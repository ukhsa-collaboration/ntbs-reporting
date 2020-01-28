/***************************************************************************************************
Desc:    This handles an exception in a way that information about the problem gets logged to the
         Windows Event Viewer, but this proc can easily be adjusted to log to any other log instead.
		 The end-user in SSRS only gets returned a generic error message, but no exploitable 
		 details about the problem.


         
**************************************************************************************************/

Create PROCEDURE [dbo].[uspHandleException] AS
	BEGIN TRY
		BEGIN
			-- Compile error message for investigation
		--	DECLARE @ErrorMsg AS VARCHAR(1000);
			-- Compile error message
		/*	DECLARE @ErrorMsg AS VARCHAR(1000) = CHAR(13) + CHAR(13) +
												 'Message: ' + ERROR_MESSAGE() + CHAR(13) +
												 'Proc: ' + ERROR_PROCEDURE() + CHAR(13) +
												 'Line: ' + CONVERT(VARCHAR, ERROR_LINE()) + CHAR(13) +
												 'Error no: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + CHAR(13) +
												 'Username: ' + SUSER_SNAME()
	*/
		INSERT INTO dbo.ErrorLog (ErrorDateTime,UserName,ErrorNumber,ErrorMessage,ProcName,LineNumber)
			VALUES (GETUTCDATE(),  SYSTEM_USER, CONVERT(VARCHAR, ERROR_NUMBER()),ERROR_MESSAGE(),ERROR_PROCEDURE(),CONVERT(VARCHAR, ERROR_LINE()))

			-- Log error
		--	EXEC [$(master)].sys.xp_logevent 60000, @ErrorMsg

			-- Display error
			SELECT ERROR_MESSAGE() AS 'ErrorMessage'
		END
	END TRY
	BEGIN CATCH
		RAISERROR ('The SQL Stored Procedure dbo.uspHandleException failed to log an error and to return a user-friendly error message to the end-user', 16, 1) WITH NOWAIT;
	END CATCH
