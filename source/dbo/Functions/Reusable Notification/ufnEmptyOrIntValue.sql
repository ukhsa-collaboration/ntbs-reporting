/***************************************************************************************************
Desc:    This function has been copied over from the ETS database that we report on.
         It receives a value from an ETS data point that consists of a fixed list of possible
		 values and transposes that list with a fixed list of other values (else returns the 
		 input value itself).


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnEmptyOrIntValue](@value int) RETURNS int AS
BEGIN 
DECLARE @display int
SET @display = case @value when '' then null when 0 then null else convert(int, @value) end
RETURN @display
END