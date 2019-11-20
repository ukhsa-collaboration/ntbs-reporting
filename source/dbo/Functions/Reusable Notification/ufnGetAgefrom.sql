/***************************************************************************************************
Desc:    This function returns the age given the birth date and a reference date

**************************************************************************************************/

Create FUNCTION [dbo].[ufnGetAgefrom] (
       @BirthDate DATETIME,
       @CurrentDate DATETIME
)
       RETURNS VARCHAR(11)
AS
       BEGIN
              DECLARE @ReturnValue AS int = NULL
              set @ReturnValue =  DATEDIFF(YY, @BirthDate, @CurrentDate) - CASE WHEN( (MONTH(@BirthDate)*100 + DAY(@BirthDate)) > (MONTH(@CurrentDate)*100 + DAY(@CurrentDate)) ) THEN 1 ELSE 0 END
              RETURN @ReturnValue
       END
GO

