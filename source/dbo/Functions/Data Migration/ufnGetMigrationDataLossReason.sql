CREATE FUNCTION [dbo].[ufnGetMigrationDataLossReason]
(
	@InputString NVARCHAR(50) = NULL
)
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @EndPos INT = CHARINDEX('.', @InputString)

	IF @EndPos > 0
	BEGIN
		SET @InputString = LEFT(@InputString, @EndPos-1)
	END

	
	SELECT @InputString = 
		CASE	
			WHEN @InputString = 'had test results without a date set' THEN 'Test results with no date'
			WHEN @InputString = 'had test results with date set in future' THEN 'Test results with future date'
			WHEN @InputString = 'invalid contact tracing figures' THEN 'Invalid contact tracing figures'
			ELSE @InputString
		END
	
	
	RETURN @InputString
END
