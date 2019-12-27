CREATE PROCEDURE [dbo].[uspLabSpecimenSecondLineSensitivityResult]
	@GroupName nvarchar(5) = NULL
AS
	
	BEGIN TRY
		SET NOCOUNT ON
		
			DECLARE @Sql NVARCHAR(2000)

			--DEBUGGING
			--SET @GroupName = 'AMINO'


			--first update the records which do have a result to the result with the lowest ranking - this indicates the highest severity
			SET @Sql = 'UPDATE [dbo].LabSpecimen
			SET ' + @GroupName + ' = Q2.ResultOutputName FROM
				-- second query joins the Rank number to the matching result
				(SELECT DISTINCT Q1.ReferenceLaboratoryNumber, rm.ResultOutputName FROM

					-- innermost query, finds the lowest ranked result for the second line group
					(SELECT DISTINCT vr.ReferenceLaboratoryNumber, MIN(vr.[Rank]) As ''MinRank'' FROM 
							[dbo].vwSusceptibilityResult vr
							INNER JOIN [dbo].[LabSpecimen] ls ON 
								vr.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
							WHERE vr.AntibioticOutputName IN (SELECT AntibioticOutputName from vwSecondLineMapping WHERE GroupName = ''' + @GroupName + ''')
								GROUP BY vr.ReferenceLaboratoryNumber) AS Q1
				INNER JOIN [dbo].ResultMapping rm ON Q1.MinRank = rm.[Rank]) as Q2
				WHERE [dbo].LabSpecimen.ReferenceLaboratoryNumber = Q2.ReferenceLaboratoryNumber'

			

			PRINT @Sql
			EXEC sp_executesql @Sql
	

	
			--then update the records with no result for the specified antibiotic
			SET @Sql = 'UPDATE LabSpecimen
				SET ' + @GroupName + ' = ''No result''
				WHERE ReferenceLaboratoryNumber NOT IN 
				(SELECT DISTINCT vr.ReferenceLaboratoryNumber from [dbo].vwSusceptibilityResult vr
				where vr.AntibioticOutputName IN (SELECT AntibioticOutputName from vwSecondLineMapping WHERE GroupName = ''' + @GroupName + '''))'

			PRINT @Sql
			EXEC sp_executesql @Sql

END TRY
BEGIN CATCH
	THROW
END CATCH
