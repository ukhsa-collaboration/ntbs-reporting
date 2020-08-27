/*
Returns consolidated information about an isolate's drug sensitivity results, 
summarising data from local copies of LabBase data
*/

CREATE FUNCTION [dbo].[ufnGetIsolateSusceptibilityInfo](@OpieId NVARCHAR(50))

RETURNS TABLE 
AS
RETURN
	
		WITH
		/*SET UP THE LOOKUP VALUES */
			
			--list of all the drug codes
			--TODO: replace with lookup table
			AllDrugNames(AntibioticOutputName) AS
			(SELECT [AntibioticOutputName]
				FROM [dbo].[AntibioticLookup]
				),

			--then a list of the result output values (e.g. 'Sensitive')
			DistinctOutputNames([Rank],[ResultOutputName]) AS
			(SELECT DISTINCT [Rank], [ResultOutputName] FROM [dbo].ResultMapping),

		/*END OF LOOKUP VALUE SET-UP*/

		--fetch the highest ranked result for each first line drug and the second line drug groups
		AvailableResults(AntibioticOutputName, [Rank]) AS
		(
			SELECT DISTINCT am.AntibioticOutputName, MIN(rm.[Rank])
				FROM StandardisedLabbaseSpecimen lbs
					--INNER JOIN LabSpecimen ls ON ls.ReferenceLaboratoryNumber = lbs.ReferenceLaboratoryNumber
					INNER JOIN [$(Labbase2)].dbo.Susceptibility su ON su.LabDataID = lbs.LabDataID
					LEFT OUTER JOIN [dbo].[AntibioticMapping] am  ON am.AntibioticCode = su.AntibioticCode
					LEFT OUTER JOIN [dbo].[ResultMapping] rm  ON rm.Result = su.SusceptibilityResult
				WHERE ResultOutputName IN ('Sensitive', 'Resistant')
				AND lbs.OpieId = @OpieId
				GROUP BY lbs.OpieId, AntibioticOutputName),
	

		--then format these so one row per drug, even if no result
		--along with the result output name appropriate to the highest ranked result
		
		AllResults(AntibioticOutputName, ResultOutputName) AS

		(SELECT a.AntibioticOutputName, LEFT(COALESCE(dm.ResultOutputName, ''), 1) As 'ResultOutputName'
		FROM AllDrugNames a
			LEFT OUTER JOIN AvailableResults ar ON ar.AntibioticOutputName = a.AntibioticOutputName
			LEFT OUTER JOIN DistinctOutputNames dm ON dm.[Rank] = ar.[Rank])

		
		--and then pivot them, so we only return one row for the given RefLabNumber

		SELECT * FROM AllResults
		AS source
		PIVOT
			(
				MAX(ResultOutputName)
				FOR [AntibioticOutputName] IN ([INH], [RIF], [EMB], [PZA], [STR], [AK], [AZI], [CAP], [CIP], [CLA], [CLO], [CYC], [ETI], [PAS], [PRO], [RB], [MFX], [OFX], [KAN], [LZD])
		) AS Result
