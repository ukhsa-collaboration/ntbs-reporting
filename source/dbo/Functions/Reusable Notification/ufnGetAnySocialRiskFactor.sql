/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.AnySocialRiskFactor
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetAnySocialRiskFactor] (
	@MisUse TINYINT,
	@ProblemUse TINYINT,
	@Homeless TINYINT,
	@PrisonAtDiagnosis TINYINT
)
	RETURNS VARCHAR(30)
AS
	BEGIN
		DECLARE @ReturnValue AS VARCHAR(30) = NULL

		-- 1. One or more of the fields which indicate a social risk factor (see list below) has the value 1
		IF (@ReturnValue IS NULL)
			IF (@MisUse = 1 OR @ProblemUse = 1 OR @Homeless = 1 OR @PrisonAtDiagnosis = 1)
				SET @ReturnValue = 'Yes'

		-- 2. All fields which indicate a social risk factor (see list below) have the value 0
		IF (@ReturnValue IS NULL)
			IF (@MisUse = 0 AND @ProblemUse = 0 AND @Homeless = 0 AND @PrisonAtDiagnosis = 0)
				SET @ReturnValue = 'No'

		-- 3. All fields which indicate a social risk factor (see list below) have the value 2
		IF (@ReturnValue IS NULL)
			IF (@MisUse = 2 AND @ProblemUse = 2 AND @Homeless = 2 AND @PrisonAtDiagnosis = 2)
				SET @ReturnValue = 'Unknown'

		-- 4. Fields are a mixture of 0, 2 and NULL
		IF (@ReturnValue IS NULL)
			IF ((@MisUse = 0 OR @MisUse = 2 OR @MisUse IS NULL) AND (@ProblemUse = 0 OR @ProblemUse = 2 OR @ProblemUse IS NULL) AND (@Homeless = 0 OR @Homeless = 2 OR @Homeless IS NULL) AND (@PrisonAtDiagnosis = 0 OR @PrisonAtDiagnosis = 2 OR @PrisonAtDiagnosis IS NULL))
				SET @ReturnValue = ''

		-- 5. An error has occurred
		IF (@ReturnValue IS NULL)
			SET @ReturnValue = 'Error: Invalid value'

		RETURN @ReturnValue;
	END
