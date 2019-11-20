/***************************************************************************************************
Desc:    This function has been copied over from the ETS database that we report on.
         It receives a value from an ETS data point that consists of a fixed list of possible
		 values and transposes that list with a fixed list of other values.

		 AireLogic have added to this function that it now also checks for an ELSE condition. 
		 This catch-all condition will return the string "Error: Invalid value" as a safeguard, 
		 so that no possibilities are unaccounted for.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnYesNoNotknown](@value int) RETURNS nvarchar(30)AS
BEGIN 
DECLARE @display nvarchar(30)
SET @display = case @value when 1 then 'Yes' when 2 then 'No' when 3 then 'Not known' when NULL then '' else 'Error: Invalid value "' + convert(VARCHAR(10), @value) + '"' end
RETURN @display
END