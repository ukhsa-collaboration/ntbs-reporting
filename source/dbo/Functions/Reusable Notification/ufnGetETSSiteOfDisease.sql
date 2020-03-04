/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.SiteOfDisease
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetETSSiteOfDisease] (
	@TuberculosisEpisodeId UNIQUEIDENTIFIER
)
	RETURNS NVARCHAR(50)
AS
	BEGIN
		DECLARE @ReturnValue AS NVARCHAR(50) = NULL

		-- 3. Sites of disease include Pulmonary (LegacyId=1), Laryngeal (LegacyID=11), Miliary (LegacyID=12), set field to 'Pulmonary'
		-- 4. Sites of disease do not include Pulmonary (LegacyId=1), Laryngeal (LegacyID=11), Miliary (LegacyID=12), set field to 'Extra-pulmonary'
		SET @ReturnValue = (SELECT TOP 1
								(CASE
									WHEN d.LegacyId = 1 THEN 'Pulmonary' -- Set to Pulmonary
									WHEN d.LegacyId = 11 THEN 'Pulmonary'
									WHEN d.LegacyId = 12 THEN 'Pulmonary'
									ELSE 'Extra-pulmonary' -- All records that are not "Pulmonary" or "Unknown" are set to be "Extra-pulmonary"
								END) AS SiteOfDisease
							FROM [$(ETS)].dbo.TuberculosisEpisodeDiseaseSite t
								INNER JOIN [$(ETS)].dbo.DiseaseSite d ON d.Id = t.DiseaseSiteId
							WHERE t.AuditDelete IS NULL
								AND d.LegacyId != 16 -- Set to Unknown in all other cases (see below)
								AND t.TuberculosisEpisodeId = @TuberculosisEpisodeId
							ORDER BY SiteOfDisease DESC) -- Pulmonary record(s) to come out on top

		-- 1. Patient has no site of disease records
		-- 2. All sites of disease are 'Unknown' (LegacyId=16)
		IF (@ReturnValue IS NULL)
			SET @ReturnValue = 'Unknown'

		RETURN @ReturnValue
	END
