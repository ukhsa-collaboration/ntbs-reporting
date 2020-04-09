/**
This will populate the companion table PeriodicOutcome with records for a given time period
First it looks for all notifications which have events within the time period
Then it looks for all notifications which should have an event within the time period:
- the notification is old enough that could have events within the time period (i.e. if time period is 2, events in year 2)
AND the most recent outcome in preceding periods was not an ending one, i.e. treatment restart

Using 24 months as an example, the conditions we have to satisfy:

	
		1. 24 month outcome is present (whether expected or not)

		2. 24 month outcome is expected and not present

		3. No 24 month outcome is expected
    			-final at 12 + no further events
    			-not yet time for there to be one
    
		For this last category, no record will be inserted into the PeriodicOutcome table


**/

CREATE PROCEDURE [dbo].[uspGenerateReusableOutcomePeriodic]
	@TimePeriod INT = 0
AS
	
	--first insert a record into PeriodicOutcome where one exists for the notification in the time period
	INSERT INTO [dbo].PeriodicOutcome (NotificationId, TimePeriod, OutcomeValue, IsFinal)
		SELECT o.NotificationId, @TimePeriod, po.OutcomeValue, po.EndingEvent from [dbo].Outcome o
		CROSS APPLY ufnGetPeriodicOutcome(@TimePeriod, o.NotificationId) po

	--then add a record with 'No outcome recorded' if an outcome was expected but does not exist
	 
	--for period 1, this should not be necessary because every notification should have a 'TreatmentStart' event within the first 12 months (i.e. on day 1)
	--so should all have been dealt with by the clause above
	IF @TimePeriod > 1
		INSERT INTO [dbo].PeriodicOutcome (NotificationId, TimePeriod, OutcomeValue, IsFinal)
			SELECT NotificationId, @TimePeriod, 'No outcome recorded', 0  FROM [dbo].[Outcome] o 
			--find the records that are old enough for inclusion - they should be older by at least one day than the end of the previous time period
			WHERE GETUTCDATE() > DATEADD(YEAR, @TimePeriod-1, o.TreatmentStartDate)
			--and the previous period's outcome was non-final
			AND o.NotificationId IN 
			(SELECT po.NotificationId FROM [dbo].[PeriodicOutcome] po 
				WHERE po.IsFinal = 0
				AND po.TimePeriod = @TimePeriod-1)
			--and we haven't already found an outcome for them in this time period
			AND o.NotificationId NOT IN 
				(SELECT po.NotificationId FROM [dbo].[PeriodicOutcome] po WHERE TimePeriod = @TimePeriod)
	


RETURN 0
