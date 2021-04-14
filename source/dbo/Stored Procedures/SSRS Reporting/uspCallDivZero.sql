CREATE PROCEDURE [dbo].[uspCallDivZero] 
	
AS
BEGIN
	BEGIN TRY
		EXEC dbo.uspDivZero
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
END