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


-- The logic of this code must stay in sync between the application and the reporting service.
-- The source of truth is documented in https://airelogic-nis.atlassian.net/wiki/spaces/R2/pages/599687169/Outcomes+logic
SELECT TOP(1) 
	@NotificationId AS 'NotificationId',
	@TimePeriod AS 'Period', 
	--ensure that if there is an ending and not-ending event (like a transfer or restart) on the last day in the period that has event data
	--(e.g. outcome and restart recorded on the same day)
	-- that we will have a consistent order, with restart taken in preference to the outcome
	(CASE
		WHEN te.TreatmentEventType = 'DiagnosisMade' THEN 1
		WHEN te.TreatmentEventType = 'TreatmentStart' THEN 2
		WHEN te.TreatmentEventType = 'TransferOut' THEN 3
		WHEN te.TreatmentEventType = 'TransferIn' THEN 4
		WHEN te.TreatmentEventType = 'TreatmentRestart' THEN 5
		WHEN te.TreatmentEventType = 'TreatmentOutcome' THEN 6
		ELSE 7
		END) AS EventOrder,
	--calculate whether the event is an ending one or not
	(CASE 
		WHEN tro.TreatmentOutcomeSubType <> 'StillOnTreatment' THEN 1
		ELSE 0
		END) AS EndingEvent,
	 COALESCE(ol.OutcomeDescription, 'No outcome recorded') AS 'OutcomeValue',
	 tro.TreatmentOutcomeSubType,
	 CASE 
		WHEN subtype.OutcomeDescription IS NOT NULL THEN CONCAT(ol.OutcomeDescription, ' - ', subtype.OutcomeDescription)
		ELSE COALESCE(ol.OutcomeDescription, 'No outcome recorded')
		END
	 AS 'DescriptiveOutcome',
	 te.EventDate,
	 te.Note
	FROM [$(NTBS)].[dbo].[TreatmentEvent] te 
	LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[TreatmentOutcome] tro ON tro.TreatmentOutcomeId = te.TreatmentOutcomeId
	LEFT OUTER JOIN [dbo].[OutcomeLookup] ol ON ol.OutcomeCode = tro.TreatmentOutcomeType
	LEFT OUTER JOIN [dbo].[OutcomeLookup] subtype ON subtype.OutcomeCode = tro.TreatmentOutcomeSubType
	INNER JOIN [dbo].[Outcome] o ON o.NotificationId = te.NotificationId
	--look for records which are on or after the start of the period
	WHERE te.EventDate >= DATEADD(YEAR, @TimePeriod-1, o.NotificationStartDate)
		--and before the end of the period.  Adding a year in this way deals with the problem of leap days
		AND te.EventDate < DATEADD(YEAR, @TimePeriod, o.NotificationStartDate)
		AND te.NotificationId = @NotificationId

	ORDER BY te.EventDate DESC, EventOrder DESC
	
