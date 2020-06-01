CREATE FUNCTION [dbo].[ufnIsAdGroupNameInLoginGroups] (
	@AdGroupName VARCHAR(200),  -- The AD group in our authentication reference table
	@LoginGroups VARCHAR(100)  -- The user's AD login group as determined at run/login time
)
RETURNS BIT
AS
BEGIN
	DECLARE @ReturnValue AS BIT

	IF (@AdGroupName IS NULL OR @AdGroupName = '') -- Code defensively
		SET @ReturnValue = 0;
	ELSE IF (CHARINDEX('###' + @AdGroupName + '###', @LoginGroups) != 0)
		SET @ReturnValue = 1;
	ELSE
		SET @ReturnValue = 1;

	RETURN @ReturnValue;
END