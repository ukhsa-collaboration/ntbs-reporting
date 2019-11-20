/***************************************************************************************************
Desc:    This can be used to mask single data points within a notification record basedon permisions
         (instead of not returning the whole notification record).
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnMaskField](
	@AdGroupName VARCHAR(200),  -- The AD group in our authentication reference table
	@LoginGroups VARCHAR(100),  -- The user's AD login group as determined at run/login time
	@FieldValue NVARCHAR(255)   -- The field value to be masked (or returned as is)
) 
	RETURNS NVARCHAR(255) 
AS
	BEGIN
		DECLARE @ReturnValue AS NVARCHAR(255)

		IF (@AdGroupName IS NULL OR @AdGroupName = '') -- Code defensively
			SET @ReturnValue = NULL;
		ELSE IF (CHARINDEX('###' + @AdGroupName + '###', @LoginGroups) != 0)
			SET @ReturnValue = @FieldValue;
		ELSE
			SET @ReturnValue = NULL; -- Mask value, cos notification belongs to other AD Group

		RETURN @ReturnValue;
	END
