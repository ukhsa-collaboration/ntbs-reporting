/**
For a given notification and time period (1 = 12 months, 2 = 24 months, 3 = 36 months)
this function will return the most recent treatment event and determine whether it represents an 'ending' event like
a real treatment outcome
**/


CREATE FUNCTION [dbo].[ufnGetPeriodicOutcome]
(
	@TimePeriod int,
	@NotificationId int
)
RETURNS TABLE
AS
RETURN

--DECLARE @TimePeriod AS INT = 1


SELECT TOP(1) 
	@NotificationId AS 'NotificationId',
	@TimePeriod AS 'Period', 
	--ensure that if there is an ending and not-ending event (like a transfer or restart) on the last day in the period that has event data
	--(e.g. outcome and restart recorded on the same day)
	--the restart will be taken in preference to the outcome
	(CASE WHEN te.TreatmentEventType = 'TreatmentOutcome' THEN 0 ELSE 1 END) AS EventOrder,
	--calculate whether the event is an ending one or not
	(CASE 
		WHEN tro.TreatmentOutcomeType != 'NotEvaluated' THEN 1 
		WHEN tro.TreatmentOutcomeType = 'NotEvaluated' AND tro.TreatmentOutcomeSubType = 'TransferredAbroad' THEN 1
		ELSE 0
		END) AS EndingEvent,
	 COALESCE(ol.OutcomeDescription, 'No outcome recorded') AS 'OutcomeValue'
	FROM [$(NTBS)].[dbo].[TreatmentEvent] te 
	LEFT OUTER JOIN [$(NTBS)].[dbo].[TreatmentOutcome] tro ON tro.TreatmentOutcomeId = te.TreatmentOutcomeId
	LEFT OUTER JOIN [dbo].[OutcomeLookup] ol ON ol.OutcomeCode = tro.TreatmentOutcomeType 
	INNER JOIN [dbo].[Outcome] o ON o.NotificationId = te.NotificationId
	--look for records which are on or after the start of the period
	WHERE DATEDIFF(DAY, o.TreatmentStartDate, te.EventDate) >= DATEDIFF(DAY, o.TreatmentStartDate, DATEADD(YEAR, @TimePeriod-1, o.TreatmentStartDate))
		--and before the end of the period.  Adding a year in this way deals with the problem of leap days
		AND DATEDIFF(DAY, o.TreatmentStartDate, te.EventDate) < DATEDIFF(DAY, o.TreatmentStartDate, DATEADD(YEAR, @TimePeriod, o.TreatmentStartDate))
		AND  te.NotificationId = @NotificationId

	ORDER BY te.EventDate DESC, EventOrder DESC
	