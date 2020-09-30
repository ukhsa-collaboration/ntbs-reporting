CREATE FUNCTION [dbo].[ufnGetMigrationNotificationId]
(
	@InputString NVARCHAR(50)
)
RETURNS NVARCHAR(12)
AS
BEGIN

	DECLARE @StartPos INT = PATINDEX('%[0-9]%', @InputString)

	--remove any characters to the left of the first number
	SET @InputString = RIGHT(@InputString, LEN(@InputString)-@StartPos+1)

	--now we want the first character that is not a number or a hyphen
	SET @StartPos = PATINDEX('%[^0-9-]%', @InputString)

	SET @InputString = LEFT(@InputString, @StartPos-1)
	RETURN @InputString

END
