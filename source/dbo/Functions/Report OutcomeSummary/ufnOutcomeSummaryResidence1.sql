/***************************************************************************************************
Desc:    This is the SQL that delivers the "Outcome Summary" residence data for the "LastOutcome" columns


         
**************************************************************************************************/

CREATE FUNCTION dbo.ufnOutcomeSummaryResidence1 (
	@NotificationDateFrom			CHAR(10)		=	NULL,
	@NotificationDateTo				CHAR(10)		=	NULL,
	@Region							VARCHAR(50)		=	NULL,
	@ResistantId					VARCHAR(50)		=	NULL, -- TODO: This should be an INTEGER, but somehow an INTEGER does not get passed through!
	@DrugResistanceProfile			VARCHAR(50)		=	NULL
)
	RETURNS TABLE
AS
RETURN
	SELECT
		n.LocalAuthority						AS 'Local Authority',
		SUM(o.TreatmentCompletedLastOutcome)	AS 'Treatment completed',
		SUM(o.DiedLastOutcome)					AS 'Died',
		SUM(o.LostToFollowUpLastOutcome)		AS 'Lost to follow-up',
		SUM(o.StillOnTreatmentLastOutcome)		AS 'Still on treatment',
		SUM(o.TreatmentStoppedLastOutcome)		AS 'Treatment stopped',
		SUM(o.NotEvaluatedLastOutcome)			AS 'Not evaluated',
		SUM(o.UnknownLastOutcome)				AS 'Unknown'
	FROM dbo.ReusableNotification n WITH (NOLOCK)
		INNER JOIN dbo.OutcomeSummary o ON o.NotificationId = n.NotificationId
		INNER JOIN dbo.DrugResistanceProfile d ON d.DrugResistanceProfile = n.DrugResistanceProfile
		INNER JOIN dbo.Resistant re ON d.ResistantId = re.ResistantId
	WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
		AND (@Region IS NULL OR n.ResidencePhec = @Region)
		AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
		AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
		AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
	GROUP BY n.LocalAuthority
