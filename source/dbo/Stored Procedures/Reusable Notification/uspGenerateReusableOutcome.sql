﻿/*This will calculate 12, 24, 36 and Last Recorded outcomes for NTBS notifications
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

		3. 24 month outcome is expected and not present*/


	
		/*First set the ones that are present
			- set the ones that are outcomes to the outcome
			- set the ones that aren't outcomes (i.e. transfers, treatment restart) to 'No outcome recorded'*/
		UPDATE [dbo].[Outcome] SET TreatmentOutcome24Months = Q2.[TwentyFourMonthOutcome], TreatmentOutcome24MonthsSubType = Q2.TreatmentOutcomeSubType
		FROM
			--outer query joins the most recent event between 12 and 24 months back to the event details
			(SELECT n.NotificationID, COALESCE(tro.TreatmentOutcomeType, 'No outcome recorded') AS 'TwentyFourMonthOutcome', te.TreatmentEventType, tro.TreatmentOutcomeSubType FROM
			[$(NTBS)].[dbo].[Notification] n
				--inner join as we only want a record for each notification which has an event 
				INNER JOIN
				--innermost query - first find the most recent event for each notification
				(SELECT n.[NotificationId], MAX([EventDate]) AS 'MaxEvent'
				  FROM [$(NTBS)].[dbo].[TreatmentEvent] te
				  INNER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = te.NotificationId
				  INNER JOIN [$(NTBS)].[dbo].ClinicalDetails cd ON cd.NotificationId = n.NotificationId
				  WHERE DATEDIFF(DAY, COALESCE(cd.TreatmentStartDate, n.NotificationDate), te.EventDate) > 365 AND DATEDIFF(DAY, COALESCE(cd.TreatmentStartDate, n.NotificationDate), te.EventDate) < 731
				  GROUP BY n.[NotificationId]
				  ) AS Q1 ON Q1.NotificationId = n.NotificationId
  			LEFT OUTER JOIN [$(NTBS)].[dbo].[TreatmentEvent] te ON te.NotificationId = n.NotificationId AND te.EventDate = Q1.MaxEvent
			LEFT OUTER JOIN [$(NTBS)].[dbo].[TreatmentOutcome] tro ON tro.TreatmentOutcomeId = te.TreatmentOutcomeId) AS Q2
		WHERE Q2.NotificationId = [dbo].[Outcome].NotificationId

		/*Now set the records where no outcome is expected - the 12 month outcome was a final one or the record is less than 12 months old*/

		UPDATE [dbo].[Outcome] SET TreatmentOutcome24Months = '' WHERE
			(TreatmentOutcome12Months != 'No outcome recorded'
			OR (TreatmentOutcome12Months = 'NotEvaluated' AND TreatmentOutcome12MonthsSubType = 'TransferredAbroad')
			OR DATEDIFF(DAY, TreatmentStartDate, GETUTCDATE()) < 366)
			AND TreatmentOutcome24Months IS NULL

		/*Finally, everything now left where TreatmentOutcome24Months is NULL should have a value but doesn't*/

		UPDATE [dbo].[Outcome] SET TreatmentOutcome24Months = 'No outcome recorded' WHERE TreatmentOutcome24Months IS NULL

		--TODO: consider what this means for the banner - should it start saying 'No outcome recorded' as soon as the clock ticks over to the start of year 2, even if the user
		--entered 'still on treatment' the day before?


	--36 MONTH OUTCOME

	/*Conditions we have to satisfy:

		1. No 36 month outcome is expected
    			-final at 12 or 24 + no further events
    			-not yet time for there to be one
    
		2. 36 month outcome is present (whether expected or not)

		3. 36 month outcome is expected and not present*/


	
		/*First set the ones that are present
			- set the ones that are outcomes to the outcome
			- set the ones that aren't outcomes (i.e. transfers, treatment restart) to 'No outcome recorded'*/

		UPDATE [dbo].[Outcome] SET TreatmentOutcome36Months = Q2.[ThirtySixMonthOutcome], TreatmentOutcome24MonthsSubType = Q2.TreatmentOutcomeSubType
		FROM
			--outer query joins the most recent event between 12 and 24 months back to the event details
			(SELECT n.NotificationID, COALESCE(tro.TreatmentOutcomeType, 'No outcome recorded') AS 'ThirtySixMonthOutcome', te.TreatmentEventType, tro.TreatmentOutcomeSubType FROM
			[$(NTBS)].[dbo].[Notification] n
				--inner join as we only want a record for each notification which has an event 
				INNER JOIN
				--innermost query - first find the most recent event for each notification
				(SELECT n.[NotificationId], MAX([EventDate]) AS 'MaxEvent'
				  FROM [$(NTBS)].[dbo].[TreatmentEvent] te
				  INNER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = te.NotificationId
				  INNER JOIN [$(NTBS)].[dbo].ClinicalDetails cd ON cd.NotificationId = n.NotificationId
				  WHERE DATEDIFF(DAY, COALESCE(cd.TreatmentStartDate, n.NotificationDate), te.EventDate) > 731 
				  GROUP BY n.[NotificationId]
				  ) AS Q1 ON Q1.NotificationId = n.NotificationId
  			LEFT OUTER JOIN [$(NTBS)].[dbo].[TreatmentEvent] te ON te.NotificationId = n.NotificationId AND te.EventDate = Q1.MaxEvent
			LEFT OUTER JOIN [$(NTBS)].[dbo].[TreatmentOutcome] tro ON tro.TreatmentOutcomeId = te.TreatmentOutcomeId) AS Q2
		WHERE Q2.NotificationId = [dbo].[Outcome].NotificationId

		/*Now set the records where no outcome is expected - the 12 month outcome was a final, the 24 month outcome was a final, one or the record is less than 24 months old*/

		UPDATE [dbo].[Outcome] SET TreatmentOutcome36Months = '' WHERE
			--condition 1: final at 12 months
			((TreatmentOutcome12Months != 'No outcome recorded'
			OR (TreatmentOutcome12Months = 'NotEvaluated' AND TreatmentOutcome12MonthsSubType = 'TransferredAbroad'))
			--condition 2: final at 24 months
			OR
			(TreatmentOutcome24Months != 'No outcome recorded'
			OR (TreatmentOutcome24Months = 'NotEvaluated' AND TreatmentOutcome24MonthsSubType = 'TransferredAbroad'))
			--condition 3: record is less than 24 months old
			OR DATEDIFF(DAY, TreatmentStartDate, GETUTCDATE()) < 731)
			--condition 4: TreatmentOutcome36Months does not have a value already
			AND TreatmentOutcome36Months IS NULL

		/*Finally, everything now left where TreatmentOutcome24Months is NULL should have a value but doesn't*/

		UPDATE [dbo].[Outcome] SET TreatmentOutcome36Months = 'No outcome recorded' WHERE TreatmentOutcome36Months IS NULL


	--LAST RECORDED TREATMENT OUTCOME

		--this will be calculated once the data has been moved back to the main ReusableNotification table




	--WRAP-UP STEPS

		--update the main table with the decoded values for each outcome
		--if it can be found in the look-up table it means the user has entered an outcome (these are stored as text codes in NTBS
		--so 'NotEvaluted' or 'Died')
		--if not, we have calcualted it as either an empty string or 'No outcome recorded' above

		UPDATE [dbo].ReusableNotification 
			SET 
				TreatmentOutcome12months = COALESCE(ol12.OutcomeDescription, o.TreatmentOutcome12Months),
				TreatmentOutcome24months = COALESCE(ol24.OutcomeDescription, o.TreatmentOutcome24Months),
				TreatmentOutcome36months = COALESCE(ol36.OutcomeDescription, o.TreatmentOutcome36Months)
			FROM [dbo].[Outcome] o
			  LEFT OUTER JOIN [dbo].[OutcomeLookup] ol12 ON ol12.OutcomeCode = o.TreatmentOutcome12Months
			  LEFT OUTER JOIN [dbo].[OutcomeLookup] ol24 ON ol24.OutcomeCode = o.TreatmentOutcome24Months
			  LEFT OUTER JOIN [dbo].[OutcomeLookup] ol36 ON ol36.OutcomeCode = o.TreatmentOutcome36Months
			WHERE o.NotificationId = [dbo].ReusableNotification.NotificationId


		--finally delete this table. TODO: Leave commented out for now for debugging
		--DELETE FROM [dbo].[Outcome]


RETURN 0