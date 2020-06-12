CREATE PROCEDURE [dbo].[uspDivZero] 
	
AS
BEGIN
	BEGIN TRY
		DECLARE @result INT
		--Generate divide-by-zero error
		SET @result = 55/0
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
END