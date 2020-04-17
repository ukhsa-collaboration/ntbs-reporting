/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.DateOfDeath
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetTreatmentEndDate] (
	@NotificationId int
)
	RETURNS DATE
AS
	BEGIN
		DECLARE @ReturnValue AS DATE = NULL


		SET @ReturnValue = 
			(SELECT MAX(te.EventDate) FROM [$(NTBS)].[dbo].[TreatmentEvent] te
			INNER JOIN [$(NTBS)].[ReferenceData].[TreatmentOutcome] tout ON tout.TreatmentOutcomeId = te.TreatmentOutcomeId
			WHERE tout.TreatmentOutcomeType IN ('Completed', 'Cured')
			AND te.NotificationId = @NotificationId)

		-- WARNING: Can not set to 'Error: Invalid value', cos this is a DATE column!

		RETURN @ReturnValue
	END
