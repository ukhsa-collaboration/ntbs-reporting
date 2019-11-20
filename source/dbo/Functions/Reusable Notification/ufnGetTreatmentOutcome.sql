/***************************************************************************************************
Desc:    This re/calculates the value for the data points ReusableNotification.TreatmentOutcome12months,
		 and a few other ReusableNotification data points for each notification record (every night when 
		 the uspGenerate schedule runs). The inline comments no 1, 2, 3 ... below have been copied 
		 across from the NTBS R1 specification in Confluence, and are to be kept in sync with that 
		 specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetTreatmentOutcome] (
	@Month VARCHAR(2),
	@AnswerToCompleteQuestion VARCHAR(150),
	@AnswerToIncompleteReason1 VARCHAR(150),
	@AnswerToIncompleteReason2 VARCHAR(150)
)
	RETURNS VARCHAR(30)
AS
	BEGIN
		DECLARE @ReturnValue AS NVARCHAR(30) = NULL

		-- 1. This gets evaluated before this function gets invoked!
		-- Nothing to do here!

		-- 2. The treatment outcome is recorded in AnswerToCompleteQuestion as 'Yes, the patient completed a full course of therapy'
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@AnswerToCompleteQuestion LIKE 'Yes, the patient completed a full course of therapy')
				SET @ReturnValue = 'Completed'
		END

		-- 3. The treatment outcome is recorded in any one of the three relevant fields (see below) as 'The patient was lost to follow-up before the end of treatment'
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@AnswerToCompleteQuestion = 'The patient was lost to follow-up before the end of treatment')
				SET @ReturnValue = 'Lost to follow-up'
			ELSE IF (@AnswerToIncompleteReason1 = 'The patient was lost to follow-up before the end of treatment')
				SET @ReturnValue = 'Lost to follow-up'
			ELSE IF (@AnswerToIncompleteReason2 = 'The patient was lost to follow-up before the end of treatment')
				SET @ReturnValue = 'Lost to follow-up'
		END

		-- 4. The treatment outcome is recorded in any one of the the three relevant fields (see below) as 'Patient died before or while on treatment'
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@AnswerToCompleteQuestion = 'Patient died before or while on treatment')
				SET @ReturnValue = 'Died'
			ELSE IF (@AnswerToIncompleteReason1 = 'Patient died before or while on treatment')
				SET @ReturnValue = 'Died'
			ELSE IF (@AnswerToIncompleteReason2 = 'Patient died before or while on treatment')
				SET @ReturnValue = 'Died'
		END

		-- 5. The treatment outcome is recorded in AnswerToCompleteQuestion as 'No, the patient did not complete a full course within 12 months' and the reason given in AnswerToIncompleteReason2 is one of the 'still on treatment' options listed below
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@AnswerToCompleteQuestion = 'No, the patient did not complete a full course within ' + @Month + ' months' AND (@AnswerToIncompleteReason2 = 'Planned course of treatment changed' OR @AnswerToIncompleteReason2 = 'Planned course of treatment exceeds ' + @Month + ' months' OR @AnswerToIncompleteReason2 = 'Planned course of treatment interrupted'))
				SET @ReturnValue = 'Still on treatment'
		END

		-- 6. The treatment outcome is recorded in any one of the the three relevant fields (see below) as 'Treatment stopped - but patient had TB'
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@AnswerToCompleteQuestion = 'Treatment stopped - but patient had TB')
				SET @ReturnValue = 'Treatment stopped'
			ELSE IF (@AnswerToInCompleteReason1 = 'Treatment stopped - but patient had TB')
				SET @ReturnValue = 'Treatment stopped'
			ELSE IF (@AnswerToInCompleteReason2 = 'Treatment stopped - but patient had TB')
				SET @ReturnValue = 'Treatment stopped'
		END

		-- 7. The treatment outcome is recorded in any one of the three relevant fields (see below) as one of the 'Unknown' options listed below
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@AnswerToCompleteQuestion = 'Unknown (treatment details are unavailable for this patient)' OR @AnswerToCompleteQuestion = 'The patient''s care was transferred to another clinic' OR @AnswerToCompleteQuestion = 'No treatment details available')
				SET @ReturnValue = 'Unknown'
			ELSE IF (@AnswerToInCompleteReason1 = 'Unknown (treatment details are unavailable for this patient)' OR @AnswerToInCompleteReason1 = 'The patient''s care was transferred to another clinic' OR @AnswerToInCompleteReason1 = 'No treatment details available')
				SET @ReturnValue = 'Unknown'
			ELSE IF (@AnswerToInCompleteReason2 = 'Unknown (treatment details are unavailable for this patient)' OR @AnswerToInCompleteReason2 = 'The patient''s care was transferred to another clinic' OR @AnswerToInCompleteReason2 = 'No treatment details available')
				SET @ReturnValue = 'Unknown'
		END

		-- 8. The treatment outcome is recorded in any one of the three relevant fields (see below) as 'Treatment stopped - Patient subsequently found not to have TB (including atypical mycobacterial infection)'
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@AnswerToCompleteQuestion = 'Treatment stopped - Patient subsequently found not to have TB (including atypical mycobacterial infection)')
				SET @ReturnValue = 'Patient did not have TB'
			ELSE IF (@AnswerToInCompleteReason1 = 'Treatment stopped - Patient subsequently found not to have TB (including atypical mycobacterial infection)')
				SET @ReturnValue = 'Patient did not have TB'
			ELSE IF (@AnswerToInCompleteReason2 = 'Treatment stopped - Patient subsequently found not to have TB (including atypical mycobacterial infection)')
				SET @ReturnValue = 'Patient did not have TB'
		END
			
		-- 9. The values in the relevant fields are all set to NULL
		IF (@ReturnValue IS NULL)
		BEGIN
			IF (@AnswerToCompleteQuestion IS NULL AND @AnswerToIncompleteReason2 IS NULL AND @AnswerToIncompleteReason2 IS NULL)
				SET @ReturnValue = 'Not evaluated'
		END

		-- 8. An error has occurred
		IF (@ReturnValue IS NULL)
		BEGIN
			SET @ReturnValue = 'Error: Invalid value'
		END

		RETURN @ReturnValue
	END
