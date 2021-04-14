/***************************************************************************************************
Desc:    This re/calculates the value for the data points ReusableNotification.CurrentDrugMisuse,
		 and a few other ReusableNotification data points for each notification record (every night when 
		 the uspGenerate schedule runs). The inline comments no 1, 2, 3 ... below have been copied 
		 across from the NTBS R1 specification in Confluence, and are to be kept in sync with that 
		 specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetDrugUseStatus] (
	@DrugUseStatusId INT,
	@ProblemUse TINYINT,
	@TuberculosisHistoryId UNIQUEIDENTIFIER
)
	RETURNS NVARCHAR(255)
AS
	BEGIN
		DECLARE @ReturnValue AS NVARCHAR(255) = NULL

		-- 1. The set of records contains a record which corresponds to the Drug Use Status of 1 (Current drug use)
		IF (@ProblemUse = 1)
			SET @ReturnValue = (SELECT 'Yes'
								FROM [$(ETS)].dbo.RiskFactorDrugUseStatus r
									INNER JOIN [$(ETS)].dbo.TuberculosisHistoryDrugUseStatus th ON th.DrugUseStatusId = r.Id
								WHERE th.TuberculosisHistoryId = @TuberculosisHistoryId
									AND r.LegacyId = @DrugUseStatusId)

		-- 2. Else no drug misuse, return NULL
		
		RETURN @ReturnValue
	END
