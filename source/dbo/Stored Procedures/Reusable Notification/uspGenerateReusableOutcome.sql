/*This will calculate 12, 24, 36 month outcomes for NTBS notifications
and then update ReusableNotification with the appropriate values for each*/


CREATE PROCEDURE [dbo].[uspGenerateReusableOutcome]
	
AS

	--SET UP STEPS
		--clear down the companion tables
		TRUNCATE TABLE [dbo].[Outcome]
		TRUNCATE TABLE [dbo].[PeriodicOutcome]

		--populate with base records from ReusableNotification where source system is NTBS
		--this will only contain Notified and Closed records, so Draft, Deleted and Denotified are excluded by default
		INSERT INTO [dbo].[Outcome] (NotificationId)
			SELECT NotificationID FROM ReusableNotification WHERE SourceSystem = 'NTBS'


		--now calculate the treatment start date. Where this is populated in NTBS, use this. If not, use the notification date as a proxy
		--there should be a "starting" event in the TreatmentEvent table which has the right value, with type either 'TreatmentStart' or 'DiagnosisMade'

		UPDATE [dbo].[Outcome] SET TreatmentStartDate = Q1.StartDate FROM
			(SELECT n.NotificationId, COALESCE(te.EventDate, n.NotificationDate) AS 'StartDate'
				FROM [$(NTBS)].[dbo].[Notification] n
					LEFT OUTER JOIN [$(NTBS)].[dbo].TreatmentEvent te ON te.NotificationId = n.NotificationId
					AND (te.TreatmentEventType = 'TreatmentStart' OR te.TreatmentEventType = 'DiagnosisMade')) AS Q1
			WHERE Q1.NotificationId = [dbo].[Outcome].NotificationId

		--Call the stored proc for each outcome period: 1, 2 and 3 (12 month, 24 month, 36 month)
		EXEC [dbo].[uspGenerateReusableOutcomePeriodic] 1
		EXEC [dbo].[uspGenerateReusableOutcomePeriodic] 2
		EXEC [dbo].[uspGenerateReusableOutcomePeriodic] 3
		

		--TODO: consider:
		-- 1. Do I need the Outcome table? Should the treatment start date calculation logic not just be used directly against ReusableNotification? Currently
		--	this just pulls out the treatment start date if one has been entered by the user (I guess maybe this does make sense)
		-- 2. Should I use this set of SPs to calculate the Treatment End Date, rather than doing it in ufnGetTreatmentEndDate? That is a very simple function,
		--	however.
		-- 3. At the moment this will produce some incongruous results, i.e. result for 1, result for 3 with nothing in between. This is if 1 was final but
		-- then some activity happens again during period 3.  This shouldn't happen as the notification should become read-only before it can


	--WRAP-UP STEPS

		--update the main table with the values for each outcome
		--if it can be found in the Periodic Outcome table, use this
		--if not, set it to an empty string
		

		UPDATE dbo.ReusableNotification
			SET
				TreatmentOutcome12months = COALESCE(po1.OutcomeValue, ''), 
				TreatmentOutcome24months = COALESCE(po2.OutcomeValue, ''), 
				TreatmentOutcome36months = COALESCE(po3.OutcomeValue, '') 
			FROM [dbo].[Outcome] o
				LEFT OUTER JOIN [dbo].[PeriodicOutcome] po1 ON po1.NotificationId = o.NotificationId AND po1.TimePeriod = 1
				LEFT OUTER JOIN [dbo].[PeriodicOutcome] po2 ON po2.NotificationId = o.NotificationId AND po2.TimePeriod = 2
				LEFT OUTER JOIN [dbo].[PeriodicOutcome] po3 ON po3.NotificationId = o.NotificationId AND po3.TimePeriod = 3
			WHERE dbo.ReusableNotification.NtbsId = o.NotificationId



		--finally delete this table. TODO: Leave commented out for now for debugging
		--DELETE FROM [dbo].[Outcome]
		--DELETE FROM [dbo].[PeriodicOutcome]


RETURN 0
