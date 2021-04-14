/***************************************************************************************************
Desc:    This converts 0/1/<null> values into Yes, No, <null>
To check for a null we need specify when @value IS NULL, which is why the case statement is 
a bit more verbose than usual


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnYesNo](@value int) RETURNS nvarchar(10)AS
BEGIN 
DECLARE @display nvarchar(10)
SET @display = 
	CASE
		WHEN @value IS NULL THEN NULL
		WHEN @value = 0 THEN 'No' 
		WHEN @value = 1 THEN 'Yes' 
		ELSE 'Error' 
	END
RETURN @display
END