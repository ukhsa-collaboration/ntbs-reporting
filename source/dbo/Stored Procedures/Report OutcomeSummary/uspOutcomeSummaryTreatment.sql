/***************************************************************************************************
Desc:    This serves the "Outcome Summary" notification aggregate counts for the treatment
         portion of the report's entry web page.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspOutcomeSummaryTreatment]
	(
		@NotificationYearFrom			INTEGER			=	NULL,
		@NotificationMonthFrom			INTEGER			=	NULL,
		@NotificationYearTo				INTEGER			=	NULL,
		@NotificationMonthTo			INTEGER			=	NULL,
		@Region							VARCHAR(50)		=	NULL,
		@TreatmentOutcomeTimePeriodId	VARCHAR(50)		=	NULL, -- TODO: This should be an INTEGER, but somehow an INTEGER does not get passed through!
		@ResistantId					VARCHAR(50)		=	NULL, -- TODO: This should be an INTEGER, but somehow an INTEGER does not get passed through!
		@DrugResistanceProfile			VARCHAR(50)		=	NULL,
		@Service				varchar(1000)	=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		VARCHAR(10) = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
            DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			VARCHAR(10) = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)
			SET @Service = case when len(@Service) - len(replace(@Service, ',', '')) +1 = 
					(select count(*) from TB_Service where PhecName = @Region) then 'All' else @Service end

			If (@Service <> 'All')
			Begin
				IF (@TreatmentOutcomeTimePeriodId = '1')
				BEGIN
					SELECT
						n.[Service]								AS 'TB Service',
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
						inner join TB_Service s on s.TB_Service_Name = n.Service
					WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
						and Serviceid in (select value from STRING_SPLIT(@Service, ','))
						AND (@Region IS NULL OR n.TreatmentPhec = @Region)
						AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
						AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
						AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
					GROUP BY n.[Service]
					ORDER BY n.[Service]
				END

				IF (@TreatmentOutcomeTimePeriodId = '2')
				BEGIN
					SELECT
						n.[Service]							AS 'TB Service',
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
						inner join TB_Service s on s.TB_Service_Name = n.Service
					WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
						and Serviceid in (select value from STRING_SPLIT(@Service, ','))
						AND (@Region IS NULL OR n.TreatmentPhec = @Region)
						AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
						AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
						AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
					GROUP BY n.[Service]
					ORDER BY n.[Service]
				END

				IF (@TreatmentOutcomeTimePeriodId = '3')
				BEGIN
					SELECT
						n.[Service]							AS 'TB Service',
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
						inner join TB_Service s on s.TB_Service_Name = n.Service
					WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
						and Serviceid in (select value from STRING_SPLIT(@Service, ','))
						AND (@Region IS NULL OR n.TreatmentPhec = @Region)
						AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
						AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
						AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
					GROUP BY n.[Service]
					ORDER BY n.[Service]
				END

				IF (@TreatmentOutcomeTimePeriodId = '4')
				BEGIN
					SELECT
						n.[Service]							AS 'TB Service',
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
						inner join TB_Service s on s.TB_Service_Name = n.Service
					WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
						and Serviceid in (select value from STRING_SPLIT(@Service, ','))
						AND (@Region IS NULL OR n.TreatmentPhec = @Region)
						AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
						AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
						AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
					GROUP BY n.[Service]
					ORDER BY n.[Service]
				END
			END
			
			If (@Service = 'All')
			Begin
				IF (@TreatmentOutcomeTimePeriodId = '1')
				BEGIN
					SELECT
						n.[Service]								AS 'TB Service',
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
						AND (@Region IS NULL OR n.TreatmentPhec = @Region )
						AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
						AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
						AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
					GROUP BY n.[Service]
					ORDER BY n.[Service]
				END

				IF (@TreatmentOutcomeTimePeriodId = '2')
				BEGIN
					SELECT
						n.[Service]							AS 'TB Service',
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
						AND (@Region IS NULL OR n.TreatmentPhec = @Region )
						AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
						AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
						AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
					GROUP BY n.[Service]
					ORDER BY n.[Service]
				END

				IF (@TreatmentOutcomeTimePeriodId = '3')
				BEGIN
					SELECT
						n.[Service]							AS 'TB Service',
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
						AND (@Region IS NULL OR n.TreatmentPhec = @Region )
						AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
						AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
						AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
					GROUP BY n.[Service]
					ORDER BY n.[Service]
				END

				IF (@TreatmentOutcomeTimePeriodId = '4')
				BEGIN
					SELECT
						n.[Service]							AS 'TB Service',
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
						AND (@Region IS NULL OR n.TreatmentPhec = @Region )
						AND ((@ResistantId IS NULL OR @ResistantId <> 1) OR re.ResistantId IN (2,3))
						AND ((@ResistantId IS NULL OR @ResistantId = 1) OR re.ResistantId = @ResistantId)
						AND	((@DrugResistanceProfile IS NULL OR @DrugResistanceProfile = 'All') OR n.DrugResistanceProfile = @DrugResistanceProfile)
					GROUP BY n.[Service]
					ORDER BY n.[Service]
				END
			END
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH