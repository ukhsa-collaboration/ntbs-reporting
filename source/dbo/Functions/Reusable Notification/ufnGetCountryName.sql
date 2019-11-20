/***************************************************************************************************
Desc:    This re/calculates the value for the data points ReusableNotification.TravelCountry1,
		 and a few other ReusableNotification data points for each notification record (every night when 
		 the uspGenerate schedule runs). The inline comments no 1, 2, 3 ... below have been copied 
		 across from the NTBS R1 specification in Confluence, and are to be kept in sync with that 
		 specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetCountryName] (
	@CountryId uniqueidentifier
)
	RETURNS nvarchar(255)
AS
	BEGIN
		DECLARE @CountryName as nvarchar(255) = NULL
	
		IF (@CountryId IS NOT NULL)
		BEGIN
			SET @CountryName = (SELECT Name FROM [$(ETS)].dbo.Country WHERE Id = @CountryId)

			-- Country name not found =  An error has occurred
			IF (@CountryName IS NULL)
				SET @CountryName = 'Error: Invalid value "' + CONVERT(VARCHAR(10), @CountryId) + '"'
		END

		RETURN @CountryName
	END
