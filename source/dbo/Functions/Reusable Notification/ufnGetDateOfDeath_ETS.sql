/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.DateOfDeath
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetDateOfDeath_ETS] (
	@TuberculosisEpisodeDeathDate DATETIME,
	@TreatmentOutcome12DeathDate DATETIME,
	@TreatmentOutcome24DeathDate DATETIME,
	@TreatmentOutcome36DeathDate DATETIME
)
	RETURNS DATE
AS
	BEGIN
		DECLARE @ReturnValue AS DATE = NULL

		-- 2. Date of death recorded more than once, and dates differ -- TODO: This complicated check needed ??? 

		-- 3. Set field to date of death
		SET @ReturnValue = CONVERT(DATE, (SELECT COALESCE(@TreatmentOutcome36DeathDate,
														@TreatmentOutcome24DeathDate,
														@TreatmentOutcome12DeathDate,
														@TuberculosisEpisodeDeathDate)))

		-- WARNING: Can not set to 'Error: Invalid value', cos this is a DATE column!

		RETURN @ReturnValue
	END
