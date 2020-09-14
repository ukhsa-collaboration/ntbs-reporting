CREATE FUNCTION [dbo].[ufnCalcContactTracingTotals]
(
	@AdultValue int,
	@ChildValue int
)
RETURNS INT
AS
BEGIN

	DECLARE @ReturnValue INT = NULL;

	--IF @AdultValue IS NULL AND @ChildValue IS NULL
		--nothing to do as @ReturnValue is already null

	IF @AdultValue IS NULL AND @ChildValue IS NOT NULL
		SET @ReturnValue = @ChildValue

	IF @AdultValue IS NOT NULL AND @ChildValue IS NULL
		SET @ReturnValue = @AdultValue

	IF @AdultValue IS NOT NULL AND @ChildValue IS NOT NULL
		SET @ReturnValue =  @AdultValue + @ChildValue

	RETURN @ReturnValue
END
