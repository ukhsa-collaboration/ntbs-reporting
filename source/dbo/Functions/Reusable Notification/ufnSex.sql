/***************************************************************************************************
Desc:    This function has been copied over from the ETS database that we report on.
         It receives a value from an ETS data point that consists of a fixed list of possible
         values and transposes that list with a fixed list of other values.

         AireLogic have added to this function that it now also checks for an ELSE condition. 
         This catch-all condition will return the string "Error: Invalid value" as a safeguard, 
         so that no possibilities are unaccounted for.

         We have also added the mapping from NULL to 'Unknown' as we have observed that there are
         ETS records with a NULL sex.
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnSex](@value int) RETURNS nvarchar(30)AS
BEGIN 
DECLARE @display nvarchar(30)
SET @display = case
    when @value = 0 then 'Female'
    when @value = 1 then 'Male'
    when @value = 2 then 'Unknown'
    when @value is null then 'Unknown'
    else 'Error: Invalid value' end
RETURN @display
END