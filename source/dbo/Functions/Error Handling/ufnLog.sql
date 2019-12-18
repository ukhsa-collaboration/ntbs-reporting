/***************************************************************************************************
Desc:    This logs a specified piece of text that has been passed. Currently this simply logs to 
         the Windows Event Viewer, but it can easily be adjusted to log to any other log instead.


         
**************************************************************************************************/

CREATE FUNCTION dbo.ufnLog (
	@LogText VARCHAR(500)
)
	RETURNS TINYINT
AS
	BEGIN
		SET @LogText = CHAR(13) + CHAR(13) +
						'Log: ' + @LogText + CHAR(13) +
						'Username: ' + SUSER_SNAME()

		--DECLARE @LogStatus AS TINYINT = 0
		EXEC master.dbo.xp_logevent 60000, @LogText

		RETURN 0
	END
