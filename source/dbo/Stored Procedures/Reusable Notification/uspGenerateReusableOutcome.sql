/*This will calculate 12, 24, 36 and Last Recorded outcomes for NTBS notifications
and then update ReusableNotification with the appropriate values for each*/


CREATE PROCEDURE [dbo].[uspGenerateReusableOutcome]
	
AS

	--SET UP STEPS
		--clear down the companion table
		DELETE FROM [dbo].[Outcome]

		--populate with base records from ReusableNotification where source system is NTBS
		INSERT INTO [dbo].[Outcome] (NotificationId)
			SELECT NotificationID FROM ReusableNotification WHERE SourceSystem = 'NTBS'


		--now calculate the treatment start date. Where this is populated in NTBS, use this. If not, use the notification date as a proxy
		--there should be an event in the TreatmentEvent table which has the right value, with type 'TreatmentStart'
		--right now, this hasn't been implemented, see NTBS-936. So implementing logic which avoids this for now.
		--TODO: refactor once NTBS-936 implemented.

		UPDATE [dbo].[Outcome] SET TreatmentStartDate = Q1.StartDate FROM
			(SELECT n.NotificationId, COALESCE(cd.TreatmentStartDate, n.NotificationDate) AS 'StartDate'
				FROM [$(NTBS)].[dbo].[Notification] n
					INNER JOIN [$(NTBS)].[dbo].ClinicalDetails cd ON cd.NotificationId = n.NotificationId) AS Q1
			WHERE Q1.NotificationId = [dbo].[Outcome].NotificationId


	--12 MONTH OUTCOME
		--Now populate the 12 month outcome
	

		UPDATE [dbo].[Outcome] SET TreatmentOutcome12Months = Q2.[Twelvemonthoutcome], TreatmentOutcome12MonthsSubType = Q2.TreatmentOutcomeSubType
		FROM
			(	--next query joins back from the date to the event to find out what it is
				SELECT n.NotificationID, COALESCE(tro.TreatmentOutcomeType, 'No outcome recorded') AS 'Twelvemonthoutcome', tro.TreatmentOutcomeSubType FROM
				[$(NTBS)].[dbo].[Notification] n
				LEFT OUTER JOIN
					--innermost query finds the most recent event for each notification
					(SELECT n.[NotificationId], MAX([EventDate]) AS 'MaxEvent'
					  FROM [$(NTBS)].[dbo].[TreatmentEvent] te
						INNER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = te.NotificationId
						INNER JOIN [$(NTBS)].[dbo].ClinicalDetails cd ON cd.NotificationId = n.NotificationId
					  WHERE DATEDIFF(DAY, COALESCE(cd.TreatmentStartDate, n.NotificationDate), te.EventDate) < 366
					  GROUP BY n.[NotificationId]) AS Q1 ON Q1.NotificationId = n.NotificationId

  				LEFT OUTER JOIN [$(NTBS)].[dbo].[TreatmentEvent] te ON te.NotificationId = n.NotificationId AND te.EventDate = Q1.MaxEvent
				LEFT OUTER JOIN [$(NTBS)].[dbo].[TreatmentOutcome] tro ON tro.TreatmentOutcomeId = te.TreatmentOutcomeId) AS Q2
		WHERE Q2.NotificationId = [dbo].[Outcome].NotificationId


	--24 MONTH OUTCOME
	
	
		/*Conditions we have to satisfy:

		1. No 24 month outcome is expected
    			-final at 12 + no further events
    			-not yet time for there to be one
    
		2. 24 month outcome is present (whether expected or not)

		3. 24 month outcome is expected and not present


		First set the ones that are present
			- set the ones that are outcomes to the outcome
			- set the ones that aren't outcomes (i.e. transfers, treatment restart) to 'No outcome recorded'


		Then where still null, set the ones that aren't expected to ''

		Then where still null set whatever is left to 'No outcome recorded'*/

		--for 24 month outcome, first set to '' where no 24 month outcome is expected	
			--where 12 month outcome is final
			--where 24 month outcome is not yet due

		UPDATE [dbo].[Outcome] SET TreatmentOutcome24Months = '' WHERE
			DATEDIFF(DAY, TreatmentStartDate, GETUTCDATE()) < 731
			OR TreatmentOutcome12Months = 'No outcome recorded'
			OR (TreatmentOutcome12Months = 'NotEvaluated' AND TreatmentOutcome12MonthsSubType = 'TransferredAbroad')


		/*initial query
		--24 MONTH
		SELECT n.NotificationID, CASE WHEN tro.TreatmentOutcomeType IS NULL THEN 'No outcome recorded' ELSE tro.TreatmentOutcomeType END AS '24monthoutcome', te.TreatmentEventType, tro.TreatmentOutcomeSubType FROM
		[test-ntbs].[dbo].[Notification] n
			LEFT OUTER JOIN
			--first find the most recent event for each notification
			(SELECT n.[NotificationId], MAX([EventDate]) AS 'MaxEvent'
			  FROM [test-ntbs].[dbo].[TreatmentEvent] te
			  INNER JOIN [test-ntbs].[dbo].[Notification] n ON n.NotificationId = te.NotificationId
			  WHERE DATEDIFF(DAY, n.NotificationDate, te.EventDate) > 365 AND DATEDIFF(DAY, n.NotificationDate, te.EventDate) < 731
			  GROUP BY n.[NotificationId]
			  ) AS Q1 ON Q1.NotificationId = n.NotificationId
  				LEFT OUTER JOIN [test-ntbs].[dbo].[TreatmentEvent] te ON te.NotificationId = n.NotificationId AND te.EventDate = Q1.MaxEvent
				LEFT OUTER JOIN [test-ntbs].[dbo].[TreatmentOutcome] tro ON tro.TreatmentOutcomeId = te.TreatmentOutcomeId*/





	--WRAP-UP STEPS
		--at the end when copying back to reusable, set to proper names
		--TODO: need to convert 'codes' to proper names, i.e. Lost to Lost to follow-up
		--using OutcomeLookup


RETURN 0
