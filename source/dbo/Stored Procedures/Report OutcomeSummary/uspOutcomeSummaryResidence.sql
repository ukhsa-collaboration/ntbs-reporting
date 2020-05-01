/***************************************************************************************************
Desc:    This serves the "Outcome Summary" notification aggregate counts for the residence
         portion of the report's entry web page.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspOutcomeSummaryResidence]
	(
		@NotificationYearFrom			INTEGER			=	NULL,
		@NotificationMonthFrom			INTEGER			=	NULL,
		@NotificationYearTo				INTEGER			=	NULL,
		@NotificationMonthTo			INTEGER			=	NULL,
		@Region							VARCHAR(50)		=	NULL,
		@TreatmentOutcomeTimePeriodId	VARCHAR(50)		=	NULL, -- TODO: This should be an INTEGER, but somehow an INTEGER does not get passed through!
		@ResistantId					VARCHAR(50)		=	NULL, -- TODO: This should be an INTEGER, but somehow an INTEGER does not get passed through!
		@DrugResistanceProfile			VARCHAR(50)		=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		VARCHAR(10) = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
            DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			VARCHAR(10) = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)

			IF (@TreatmentOutcomeTimePeriodId = '1')
			BEGIN
				/*
				-- This commented-out SQL statement needs to be swapped with the following SQL statement in order to fulfil the user requirement
				-- RP-871 "Clinic/LA missed from table if no data within time period" at 
				-- https://airelogic-nis.atlassian.net/secure/RapidBoard.jspa?rapidView=8&projectKey=RP&modal=detail&selectedIssue=RP-871&quickFilter=27 :
				SELECT *
				FROM dbo.ufnOutcomeSummaryResidence1(@NotificationDateFrom, @NotificationDateTo, @Region, @ResistantId, @DrugResistanceProfile)
				UNION
				SELECT
					la.LocalAuthority						AS 'Local Authority',
					0										AS 'Treatment completed',
					0										AS 'Died',
					0										AS 'Lost to follow-up',
					0										AS 'Still on treatment',
					0										AS 'Treatment stopped',
					0										AS 'Not evaluated',
					0										AS 'Unknown'
				FROM dbo.ufnGetLAsByRegion(@Region) la
					WHERE la.LocalAuthority NOT IN (SELECT [Local Authority] 
													FROM dbo.ufnOutcomeSummaryResidence1(@NotificationDateFrom, @NotificationDateTo, @Region, @ResistantId, @DrugResistanceProfile) AS existingLAs)
				ORDER BY [Local Authority]
				*/
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
				ORDER BY n.LocalAuthority
			END

			IF (@TreatmentOutcomeTimePeriodId = '2')
			BEGIN
				SELECT
					n.LocalAuthority					AS 'Local Authority',
					SUM(o.TreatmentCompleted12Month)	AS 'Treatment completed',
					SUM(o.Died12Month)					AS 'Died',
					SUM(o.LostToFollowUp12Month)		AS 'Lost to follow-up',
					SUM(o.StillOnTreatment12Month)		AS 'Still on treatment',
					SUM(o.TreatmentStopped12Month)		AS 'Treatment stopped',
					SUM(o.NotEvaluated12Month)			AS 'Not evaluated',
					SUM(o.Unknown12Month)				AS 'Unknown'
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
				ORDER BY n.LocalAuthority
			END

			IF (@TreatmentOutcomeTimePeriodId = '3')
			BEGIN
				SELECT
					n.LocalAuthority					AS 'Local Authority',
					SUM(o.TreatmentCompleted24Month)	AS 'Treatment completed',
					SUM(o.Died24Month)					AS 'Died',
					SUM(o.LostToFollowUp24Month)		AS 'Lost to follow-up',
					SUM(o.StillOnTreatment24Month)		AS 'Still on treatment',
					SUM(o.TreatmentStopped24Month)		AS 'Treatment stopped',
					SUM(o.NotEvaluated24Month)			AS 'Not evaluated',
					SUM(o.Unknown24Month)				AS 'Unknown'
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
				ORDER BY n.LocalAuthority
			END

			IF (@TreatmentOutcomeTimePeriodId = '4')
			BEGIN
				SELECT
					n.LocalAuthority					AS 'Local Authority',
					SUM(o.TreatmentCompleted36Month)	AS 'Treatment completed',
					SUM(o.Died36Month)					AS 'Died',
					SUM(o.LostToFollowUp36Month)		AS 'Lost to follow-up',
					SUM(o.StillOnTreatment36Month)		AS 'Still on treatment',
					SUM(o.TreatmentStopped36Month)		AS 'Treatment stopped',
					SUM(o.NotEvaluated36Month)			AS 'Not evaluated',
					SUM(o.Unknown36Month)				AS 'Unknown'
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
				ORDER BY n.LocalAuthority
			END			
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH