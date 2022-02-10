CREATE FUNCTION [dbo].[ufnMapYesNoToBooleanText](@value VARCHAR(5)) RETURNS NVARCHAR(5) AS
BEGIN 
DECLARE @booltext nvarchar(10)
SET @booltext = 
	CASE
		WHEN @value IS NULL THEN NULL
		WHEN @value = 'Yes' THEN 'TRUE' 
		WHEN @value = 'No' THEN 'FALSE' 
		ELSE 'Error' 
	END
RETURN @booltext
END
