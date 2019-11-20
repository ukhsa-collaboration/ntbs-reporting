/***************************************************************************************************
Desc:    This takes a @Part figure and returns the percentage of it from the @Total supplied


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnCalculatePercentage] (
	@Part FLOAT,
	@Total FLOAT
)
	RETURNS DECIMAL(4, 1)
AS
	BEGIN
		-- Default to -1 (in case calculation is unsuccessful)
		DECLARE @ReturnValue AS DECIMAL(4, 1) = -1.0

		IF (@Total > 0.0)
			SET @ReturnValue = 100 / @Total * @Part
		ELSE
			SET @ReturnValue = 0.0

		RETURN @ReturnValue
	END
