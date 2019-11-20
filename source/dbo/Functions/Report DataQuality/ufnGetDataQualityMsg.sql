/***************************************************************************************************
Desc:    This is to return (or mask) a notification record value for the "Data Quality Line List".
         Depending on whether there is a data quality problem, the valaue is getting returned, else
		 empty string


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetDataQualityMsg](@value int,@DataQualityMsg varchar(50)) RETURNS nvarchar(50)AS
BEGIN 
DECLARE @display nvarchar(30)
SET @display = case  when @value = 1 then @DataQualityMsg when @value = 0 then ''  else 'Error: Invalid Data Quality Value "' + convert(VARCHAR(10), @value) + '"' end
RETURN @display
END
