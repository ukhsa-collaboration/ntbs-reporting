/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.TreatmentEndDate
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetTreatmentEndDate_ETS] (
	@EndOfTreatmentDate12 DATETIME,
	@EndOfTreatmentDate24 DATETIME,
	@EndOfTreatmentDate36 DATETIME
)
	RETURNS DATE
AS
	BEGIN
		DECLARE @ReturnValue AS DATE = NULL

		-- 1. No treatment outcome records for notification
		IF (@EndOfTreatmentDate12 IS NULL AND @EndOfTreatmentDate24 IS NULL AND @EndOfTreatmentDate36 IS NULL)
		-- Leave NULL, cos DATE column can not be ''

		-- 2. All treatment end dates are null
		-- Same SQL condition as in no 1, so nothing to do here!

		-- 3. TreatmentOutcome36Month.EndOfTreatmentDate is not null
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@EndOfTreatmentDate36 IS NOT NULL)
				SET @ReturnValue = CONVERT(DATE, @EndOfTreatmentDate36)
		END

		-- 4. TreatmentOutcomeTwentyFourMonth.EndOfTreatmentDate is not null
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@EndOfTreatmentDate24 IS NOT NULL)
				SET @ReturnValue = CONVERT(DATE, @EndOfTreatmentDate24)
		END

		-- 5. TreatmentOutcome.EndOfTreatmentDate is not null
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@EndOfTreatmentDate12 IS NOT NULL)
				SET @ReturnValue = CONVERT(DATE, @EndOfTreatmentDate12)
		END

		-- WARNING: Can not set to 'Error: Invalid value', cos this is a DATE column!

		RETURN @ReturnValue
	END
