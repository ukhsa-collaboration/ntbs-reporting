/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.LastRecordedTreatmentOutcome
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationLastRecordedTreatmentOutcome] AS
	BEGIN TRY
		SET NOCOUNT ON

		-- 1. 36 month outcome has a non-empty/non-error value
		UPDATE dbo.ReusableNotification_ETS SET
			LastRecordedTreatmentOutcome = TreatmentOutcome36months
		WHERE LastRecordedTreatmentOutcome IS NULL
			AND TreatmentOutcome36months IS NOT NULL
			AND TreatmentOutcome36months != ''
			AND TreatmentOutcome36months != 'Error: Invalid value'

		-- 2. 24 month outcome has a non-empty/non-error value
		UPDATE dbo.ReusableNotification_ETS SET
			LastRecordedTreatmentOutcome = TreatmentOutcome24months
		WHERE LastRecordedTreatmentOutcome IS NULL
			AND TreatmentOutcome24months IS NOT NULL
			AND TreatmentOutcome24months != ''
			AND TreatmentOutcome24months != 'Error: Invalid value'

		-- 3. 12 month outcome has a non-empty/non-error value
		UPDATE dbo.ReusableNotification_ETS SET
			LastRecordedTreatmentOutcome = TreatmentOutcome12months
		WHERE LastRecordedTreatmentOutcome IS NULL
			AND TreatmentOutcome12months IS NOT NULL
			AND TreatmentOutcome12months != ''
			AND TreatmentOutcome12months != 'Error: Invalid value'

		-- 4. An error has occurred
		UPDATE dbo.ReusableNotification_ETS SET
			LastRecordedTreatmentOutcome = 'Error: Invalid value'
		WHERE LastRecordedTreatmentOutcome IS NULL
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
