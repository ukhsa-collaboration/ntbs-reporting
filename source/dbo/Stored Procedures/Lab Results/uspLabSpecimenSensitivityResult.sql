CREATE PROCEDURE [dbo].[uspLabSpecimenSensitivityResult]
	@Antibiotic nvarchar(5) = NULL
AS
	--TODO: THIS WILL REQUIRE DYNAMIC SQL
	--first update the records with no result for the specified antibiotic
	UPDATE LabSpecimen
		SET RIF = 'No Result'
		WHERE ReferenceLaboratoryNumber NOT IN 
		(SELECT DISTINCT vr.ReferenceLaboratoryNumber from [dbo].vwSusceptibilityResult vr
		where vr.AntibioticOutputName = @Antibiotic)


	--then update the records which do have a result to the result with the lowest ranking - this indicates the highest severity
	UPDATE [dbo].LabSpecimen
	SET RIF = Q2.ResultOutputName FROM
	
				/*-- second query joins the Rank number to the matching rest*/
				(SELECT DISTINCT Q1.ReferenceLaboratoryNumber, rm.ResultOutputName FROM

						-- innermost query, finds the lowest ranked result for each antibio
						(SELECT DISTINCT vr.ReferenceLaboratoryNumber, MIN(vr.[Rank]) As 'MinRank' FROM 
									[dbo].vwSusceptibilityResult vr
									INNER JOIN [dbo].[LabSpecimen] ls ON 
										vr.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
								WHERE vr.AntibioticOutputName = @Antibiotic
								GROUP BY vr.ReferenceLaboratoryNumber) as Q1
					INNER JOIN [dbo].ResultMapping rm ON Q1.MinRank = rm.[Rank]) as Q2
	WHERE [dbo].LabSpecimen.ReferenceLaboratoryNumber = Q2.ReferenceLaboratoryNumber			
RETURN 0
