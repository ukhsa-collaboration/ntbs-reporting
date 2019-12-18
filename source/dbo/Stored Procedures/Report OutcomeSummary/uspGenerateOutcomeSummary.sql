/***************************************************************************************************
Desc:    This pre-calculates the figures for the "Outcome Summary" report for performance reasons
         (this is part of the re-generation schedule every night).


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateOutcomeSummary] AS
	BEGIN TRY
		SET NOCOUNT ON

		-- Reset
		DELETE FROM dbo.OutcomeSummary

		-- Seed table with all (valid) notifications to consider
		INSERT INTO dbo.OutcomeSummary (NotificationId)
			SELECT
				NotificationId
			FROM dbo.ReusableNotification WITH (NOLOCK)

		-- Populate LAST treatment outcome
		UPDATE dbo.OutcomeSummary SET
			TreatmentCompletedLastOutcome = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Completed')

		UPDATE dbo.OutcomeSummary SET
			DiedLastOutcome = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Died')

		UPDATE dbo.OutcomeSummary SET
			LostToFollowUpLastOutcome = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Lost to follow-up')

		UPDATE dbo.OutcomeSummary SET
			StillOnTreatmentLastOutcome = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Still on treatment')

		UPDATE dbo.OutcomeSummary SET
			TreatmentStoppedLastOutcome = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Treatment stopped')

		UPDATE dbo.OutcomeSummary SET
			NotEvaluatedLastOutcome = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Not evaluated')

		UPDATE dbo.OutcomeSummary SET
			UnknownLastOutcome = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE LastRecordedTreatmentOutcome = 'Unknown' 
								 OR LastRecordedTreatmentOutcome = 'Patient did not have TB')

		-- Populate 12 MONTH treatment outcome
		UPDATE dbo.OutcomeSummary SET
			TreatmentCompleted12Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome12months = 'Completed')

		UPDATE dbo.OutcomeSummary SET
			Died12Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome12months = 'Died')

		UPDATE dbo.OutcomeSummary SET
			LostToFollowUp12Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome12months = 'Lost to follow-up')

		UPDATE dbo.OutcomeSummary SET
			StillOnTreatment12Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome12months = 'Still on treatment')

		UPDATE dbo.OutcomeSummary SET
			TreatmentStopped12Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome12months = 'Treatment stopped')

		UPDATE dbo.OutcomeSummary SET
			NotEvaluated12Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome12months = 'Not evaluated')

		UPDATE dbo.OutcomeSummary SET
			Unknown12Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome12months = 'Unknown'
								 OR TreatmentOutcome12months = 'Patient did not have TB')

		-- Populate 24 MONTH treatment outcome
		UPDATE dbo.OutcomeSummary SET
			TreatmentCompleted24Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome24months = 'Completed')

		UPDATE dbo.OutcomeSummary SET
			Died24Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome24months = 'Died')

		UPDATE dbo.OutcomeSummary SET
			LostToFollowUp24Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome24months = 'Lost to follow-up')

		UPDATE dbo.OutcomeSummary SET
			StillOnTreatment24Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome24months = 'Still on treatment')

		UPDATE dbo.OutcomeSummary SET
			TreatmentStopped24Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome24months = 'Treatment stopped')

		UPDATE dbo.OutcomeSummary SET
			NotEvaluated24Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome24months = 'Not evaluated')

		UPDATE dbo.OutcomeSummary SET
			Unknown24Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome24months = 'Unknown'
								 OR TreatmentOutcome24months = 'Patient did not have TB')

		-- Populate 36 MONTH treatment outcome
		UPDATE dbo.OutcomeSummary SET
			TreatmentCompleted36Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome36months = 'Completed')

		UPDATE dbo.OutcomeSummary SET
			Died36Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome36months = 'Died')

		UPDATE dbo.OutcomeSummary SET
			LostToFollowUp36Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome36months = 'Lost to follow-up')

		UPDATE dbo.OutcomeSummary SET
			StillOnTreatment36Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome36months = 'Still on treatment')

		UPDATE dbo.OutcomeSummary SET
			TreatmentStopped36Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome36months = 'Treatment stopped')

		UPDATE dbo.OutcomeSummary SET
			NotEvaluated36Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome36months = 'Not evaluated')

		UPDATE dbo.OutcomeSummary SET
			Unknown36Month = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE TreatmentOutcome36months = 'Unknown'
								 OR TreatmentOutcome36months = 'Patient did not have TB')
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
