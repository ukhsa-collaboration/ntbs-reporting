/***************************************************************************************************
Desc:    This logs a specified piece of text that has been passed. Currently this simply logs to 
         the Windows Event Viewer, but it can easily be adjusted to log to any other log instead.


         
**************************************************************************************************/

CREATE PROCEDURE dbo.uspLog  
	@LogText VARCHAR(500)


AS
	BEGIN
		--SET @LogText = 'Log: ' + @LogText

		--DECLARE @LogStatus AS TINYINT = 0
		insert into dbo.ErrorLog (ErrorDateTime,UserName,ErrorMessage)
		values( GETUTCDATE(),  SYSTEM_USER, @LogText)
		--EXEC [$(master)].sys.xp_logevent 60000, @LogText

		RETURN 0
	END
