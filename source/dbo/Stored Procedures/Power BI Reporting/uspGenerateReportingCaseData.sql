CREATE PROCEDURE [dbo].[uspGenerateReportingCaseData]
	
AS
BEGIN TRY	

	EXEC [dbo].[uspGenerateNtbsCaseRecord]
	
	EXEC [dbo].[uspGenerateEtsCaseRecord]
		--then call some ETS procs


		--finally do stuff that makes sense just to do for all records, like the last recorded treatment outcome and any social risk factor
		--and the look-ups for phec names, la names, tb service names, lat long, cluster

		--now populate Any Social Risk Factor - this can be done for all records, not just the NTBS ones
		UPDATE Record_CaseData
		SET AnySocialRiskFactor = CASE 
			WHEN AlcoholMisuse = 'Yes' 
				OR DrugMisuse = 'Yes' 
				OR Homeless = 'Yes' 
				OR Prison = 'Yes'
				OR MentalHealth = 'Yes'
				OR AsylumSeeker = 'Yes'
				OR ImmigrationDetainee = 'Yes'
			THEN 'Yes' ELSE 'No' END
		

			

END TRY
BEGIN CATCH
	THROW
END CATCH