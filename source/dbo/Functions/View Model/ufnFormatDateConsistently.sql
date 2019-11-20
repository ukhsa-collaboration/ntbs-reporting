/***************************************************************************************************
Desc:    This is to be applied on all (!) the dates that get returned from end-user procs. The date
         format is what PHE have specified to be their consistent way of dis;laying dates to the 
		 end-user, e.g. 14-Feb-2019.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnFormatDateConsistently] (
	@IncomingDate DATE
)
	RETURNS VARCHAR(11)
AS
	BEGIN
		DECLARE @ReturnValue AS VARCHAR(11) = NULL

		SET @ReturnValue = FORMAT(@IncomingDate, 'dd-MMM-yyyy')

		RETURN @ReturnValue
	END
