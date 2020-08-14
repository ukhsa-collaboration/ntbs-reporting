CREATE FUNCTION [dbo].[ufnGetHIVValue]
(
	@NTBSHIVValue NVARCHAR(30)
)
RETURNS NVARCHAR(100)
AS
BEGIN

	DECLARE @ReturnValue NVARCHAR(100) = NULL
	
	SET @ReturnValue = 
		CASE 
			WHEN @NTBSHIVValue = 'HIVStatusKnown' THEN 'HIV status already known'
			WHEN @NTBSHIVValue = 'NotOffered' THEN 'Not offered'
			WHEN @NTBSHIVValue = 'Offered' THEN 'Offered'
			WHEN @NTBSHIVValue = 'OfferedButNotDone' THEN 'Offered but not done'
			WHEN @NTBSHIVValue = 'OfferedButRefused' THEN 'Offered but refused'
			ELSE ''
		END

	RETURN @ReturnValue
END
