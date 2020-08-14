CREATE FUNCTION [dbo].[ufnGetLegacyDOTvalue]
(
	@NTBSDotValue NVARCHAR(30)
)
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @ReturnValue NVARCHAR(10) = NULL
	
	SET @ReturnValue = 
		CASE 
			WHEN @NTBSDotValue = 'Unknown' THEN 'Not known'
			WHEN @NTBSDotValue = 'No' THEN 'No'
			WHEN @NTBSDotValue = 'DotReceived' THEN 'Yes'
			WHEN @NTBSDotValue = 'DotRefused' THEN 'No'
			ELSE ''
		END
	
	RETURN @ReturnValue
END
