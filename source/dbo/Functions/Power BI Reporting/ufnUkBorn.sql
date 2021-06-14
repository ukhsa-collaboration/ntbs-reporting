CREATE FUNCTION [dbo].[ufnUkBorn] (
	@CountryId int
)
	RETURNS [nvarchar](10)
AS
	BEGIN
		DECLARE @IsUkBorn nvarchar(10)
		SET @IsUkBorn =
		CASE
			WHEN @CountryId IS NULL THEN NULL
			WHEN @CountryId = 235 THEN 'Yes'
			WHEN @CountryId = 238 THEN 'Unknown'
			ELSE 'No'
		END
		RETURN @IsUkBorn
	END