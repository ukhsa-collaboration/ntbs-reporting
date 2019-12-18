/***************************************************************************************************
Desc:    This handles an exception in a way that information about the problem gets logged to the
         Windows Event Viewer, and also returned to the user. Only invoke this function, if you are 
		 a DB admin user, an are meant to see this debug information on-screen, else it compromises
		 system security.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspDisplayException] AS
	BEGIN TRY
		BEGIN
			-- Compile error message
			DECLARE @ErrorMsg AS VARCHAR(1000) = CHAR(13) + CHAR(13) +
												 'Message: ' + ERROR_MESSAGE() + CHAR(13) +
												 'Proc: ' + ERROR_PROCEDURE() + CHAR(13) +
												 'Line: ' + CONVERT(VARCHAR, ERROR_LINE()) + CHAR(13) +
												 'Error no: ' + CONVERT(VARCHAR, ERROR_NUMBER()) + CHAR(13) +
												 'Username: ' + SUSER_SNAME()

			-- Log error
			EXEC master.dbo.xp_logevent 60000, @ErrorMsg

			-- Display error
			SELECT @ErrorMsg AS 'ErrorMessage'
		END
	END TRY
	BEGIN CATCH
		RAISERROR ('The SQL Stored Procedure dbo.uspDisplayException failed to return an error message to the DB admin', 16, 1) WITH NOWAIT;
	END CATCH
