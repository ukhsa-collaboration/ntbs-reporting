CREATE FUNCTION [dbo].[ufnGetEtsBirthCountryAsNtbsCountry]
(
	@UkBorn TINYINT NULL,
	@EtsBirthCountryId UNIQUEIDENTIFIER
)
	RETURNS NVARCHAR (255)
AS
BEGIN
	DECLARE @ReturnValue AS NVARCHAR(255) = NULL

	SELECT @ReturnValue = cm.CountryName
	FROM [$(OtherServer)].[$(ETS)].dbo.Country ec
		LEFT JOIN [$(migration)].dbo.CountriesMapping cm ON ec.IsoCode = cm.IsoCode
	WHERE (@UkBorn = 1 AND ec.Id = 'F9E4E391-2535-4C79-9FB3-2599DF36100C')
		OR ((@UkBorn != 1 OR @UkBorn IS NULL) AND @EtsBirthCountryId = ec.Id)

	RETURN COALESCE(@ReturnValue, 'Unknown')
END
