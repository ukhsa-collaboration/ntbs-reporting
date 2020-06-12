/*
Returns consolidated information about a lab specimen's drug sensitivity results, 
summarising data from local copies of LabBase data
*/

CREATE FUNCTION [dbo].[ufnGetSpecimenSusceptibilityInfo](@RefLabNumber NVARCHAR(50))

RETURNS TABLE 
AS
RETURN
	
		WITH
		/*SET UP THE LOOKUP VALUES */
			
			--then a list of all the drug names
			AllDrugNames(AntibioticOutputName) AS
			(SELECT [AntibioticOutputName]
				FROM [dbo].[vwFirstLineAntibiotics]
				UNION
				SELECT DISTINCT [GroupName]
				FROM [dbo].[vwSecondLineMapping]),

			--then a list of the result output values (e.g. 'Sensitive')
			DistinctOutputNames([Rank],[ResultOutputName]) AS
			(SELECT DISTINCT [Rank], [ResultOutputName] FROM [dbo].ResultMapping),

		/*END OF LOOKUP VALUE SET-UP*/

		--fetch the highest ranked result for each first line drug and the second line drug groups
		AvailableResults(AntibioticOutputName, [Rank]) AS
		(
			SELECT COALESCE(GroupName, lbsr.AntibioticOutputName) AS 'AntibioGroupname', MIN(lbsr.[Rank])
				FROM [dbo].[LabBaseSusceptibilityResult] lbsr
					LEFT OUTER JOIN [dbo].[vwSecondLineMapping] slm ON slm.AntibioticOutputName = lbsr.AntibioticOutputName
				WHERE lbsr.ReferenceLaboratoryNumber = @RefLabNumber
					AND (lbsr.AntibioticOutputName IN (SELECT [AntibioticOutputName] FROM [dbo].[vwFirstLineAntibiotics]) 
					OR	slm.GroupName IS NOT NULL)
				GROUP BY ReferenceLaboratoryNumber, COALESCE(GroupName, lbsr.AntibioticOutputName)),
	

		--then format these so one row per drug, even if no result
		--along with the result output name appropriate to the highest ranked result
		
		AllResults(AntibioticOutputName, ResultOutputName) AS

		(SELECT a.AntibioticOutputName, COALESCE(dm.ResultOutputName, 'No result') As 'ResultOutputName'
		FROM AllDrugNames a
			LEFT OUTER JOIN AvailableResults ar ON ar.AntibioticOutputName = a.AntibioticOutputName
			LEFT OUTER JOIN DistinctOutputNames dm ON dm.[Rank] = ar.[Rank])

		
		--and then pivot them, so we only return one row for the given RefLabNumber

		SELECT * FROM AllResults
		AS source
		PIVOT
			(
				MAX(ResultOutputName)
				FOR [AntibioticOutputName] IN ([INH], [RIF], [EMB], [PZA], [AMINO], [QUIN])
		) AS Result
