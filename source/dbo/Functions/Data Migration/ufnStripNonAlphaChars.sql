/*Used to remove non-alpha characters from data from the service directory*/

CREATE FUNCTION [dbo].[ufnStripNonAlphaChars]
(
	@InputText NVARCHAR(150)
)
RETURNS NVARCHAR(150)
AS
BEGIN

	DECLARE @TempString AS NVARCHAR(150) = @InputText
	Declare @KeepValues AS VARCHAR(50)
    SET @KeepValues = '%[^A-z]%'
    WHILE PATINDEX(@KeepValues, @TempString) > 0
        SET @TempString = STUFF(@TempString, PATINDEX(@KeepValues, @TempString), 1, '')

	RETURN @TempString
END
