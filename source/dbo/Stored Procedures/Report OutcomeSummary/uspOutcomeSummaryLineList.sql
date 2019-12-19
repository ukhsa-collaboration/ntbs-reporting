
/***************************************************************************************************
Desc:    This serves the "Outcome Summary Line List", which returns every/most notification data point
         in detail, based on the user's permission & filtering preference. Every notification record
		 returned gets audited, whch means a log entry gets added for each user that views a notification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspOutcomeSummaryLineList]
	(
		@NotificationYearFrom			INTEGER			=	-3,
		@NotificationMonthFrom			INTEGER			=	1,
		@NotificationYearTo				INTEGER			=	0,
		@NotificationMonthTo			INTEGER			=	1,
		@Region							VARCHAR(50)		=	NULL,
		@DrugResistanceProfile			VARCHAR(50)		=	NULL,
		@LocalAuthority					VARCHAR(50)		=	NULL,
		@ServiceName					VARCHAR(1000)	=	NULL,
		@Bucket							VARCHAR(50)		=	NULL,
		@TreatmentOutcomeTimePeriodId	VARCHAR(50)		=	NULL
	)
AS
	SET NOCOUNT ON

	-- Debugging
	-- EXEC master..xp_logevent 60000, @ResidenceTreatment
	-- EXEC master..xp_logevent 60000, @Region

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN
			/*
				-- Debugging
				DECLARE @NotificationYearFrom INTEGER, @NotificationMonthFrom INTEGER, @NotificationYearTo INTEGER, @NotificationMonthTo INTEGER, @Region VARCHAR(50), @DrugResistanceProfile VARCHAR(50), @LocalAuthority VARCHAR(50), @ServiceName VARCHAR(150), @Bucket VARCHAR(50), @LoginGroups VARCHAR(500)
				SET @LoginGroups = '###Global.NIS.NTBS.NTS###'
				SET @NotificationYearFrom =	-3
				SET @NotificationMonthFrom	= 1
				SET @NotificationYearTo	= 0
				SET @NotificationMonthTo = 12
				SET @Region	= 'London'
				SET @DrugResistanceProfile = 'All'
				SET @LocalAuthority	=	NULL
				SET @ServiceName =	'All'
				SET @Bucket	= 'Table Total'
				declare @TreatmentOutcomeTimePeriodId nvarchar(1) = '1' 
			*/

			DECLARE @NotificationYearTypeFrom	VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
            DECLARE @NotificationYearTypeTo		VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)

			IF(@DrugResistanceProfile = 'All')
				SET @DrugResistanceProfile = NULL

			--Buckets
			DECLARE @TreatmentLast TINYINT = NULL
			DECLARE @Treatment12 TINYINT = NULL
			DECLARE @Treatment24 TINYINT = NULL
			DECLARE @Treatment36 TINYINT = NULL
			DECLARE @DiedLast TINYINT = NULL
			DECLARE @Died12 TINYINT = NULL
			DECLARE @Died24 TINYINT = NULL
			DECLARE @Died36 TINYINT = NULL
			DECLARE @LostToFollowUpLast TINYINT = NULL
			DECLARE @LostToFollowUp12 TINYINT = NULL
			DECLARE @LostToFollowUp24 TINYINT = NULL
			DECLARE @LostToFollowUp36 TINYINT = NULL
			DECLARE @StillOnTreatmentLast TINYINT = NULL
			DECLARE @StillOnTreatment12 TINYINT = NULL
			DECLARE @StillOnTreatment24 TINYINT = NULL
			DECLARE @StillOnTreatment36 TINYINT = NULL
			DECLARE @TreatmentStoppedLast TINYINT = NULL
			DECLARE @TreatmentStopped12 TINYINT = NULL
			DECLARE @TreatmentStopped24 TINYINT = NULL
			DECLARE @TreatmentStopped36 TINYINT = NULL
			DECLARE @NotEvaluatedLast TINYINT = NULL
			DECLARE @NotEvaluated12 TINYINT = NULL
			DECLARE @NotEvaluated24 TINYINT = NULL
			DECLARE @NotEvaluated36 TINYINT = NULL
			DECLARE @UnknownLast TINYINT = NULL
			DECLARE @Unknown12 TINYINT = NULL
			DECLARE @Unknown24 TINYINT = NULL
			DECLARE @Unknown36 TINYINT = NULL
			DECLARE @TableTotalLast TINYINT = NULL
			DECLARE @TableTotal12 TINYINT = NULL
			DECLARE @TableTotal24 TINYINT = NULL
			DECLARE @TableTotal36 TINYINT = NULL


			IF (@Bucket = 'Treatment completed'  and @TreatmentOutcomeTimePeriodId = '1')
				SET @TreatmentLast = 1
			ELSE IF (@Bucket = 'Treatment completed'  and @TreatmentOutcomeTimePeriodId = '2')
				SET @Treatment12 = 1
			ELSE IF (@Bucket = 'Treatment completed' and @TreatmentOutcomeTimePeriodId = '3')
				SET @Treatment24 = 1
			ELSE IF (@Bucket = 'Treatment completed' and @TreatmentOutcomeTimePeriodId = '4')
				SET @Treatment36 = 1
			ELSE IF (@Bucket = 'Died' and @TreatmentOutcomeTimePeriodId = '1')
				SET @DiedLast = 1
			ELSE IF (@Bucket = 'Died' and @TreatmentOutcomeTimePeriodId = '2')
				SET @Died12 = 1
			ELSE IF (@Bucket = 'Died' and @TreatmentOutcomeTimePeriodId = '3')
				SET @Died24 = 1
			ELSE IF (@Bucket = 'Died' and @TreatmentOutcomeTimePeriodId = '4')
				SET @Died36 = 1
			ELSE IF (@Bucket = 'Lost to follow up' and @TreatmentOutcomeTimePeriodId = '1')
				SET @LostToFollowUpLast = 1
			ELSE IF (@Bucket = 'Lost to follow up' and @TreatmentOutcomeTimePeriodId = '2')
				SET @LostToFollowUp12 = 1
			ELSE IF (@Bucket = 'Lost to follow up' and @TreatmentOutcomeTimePeriodId = '3')
				SET @LostToFollowUp24 = 1
			ELSE IF (@Bucket = 'Lost to follow up' and @TreatmentOutcomeTimePeriodId = '4')
				SET @LostToFollowUp36 = 1
			ELSE IF (@Bucket = 'Still on treatment' and @TreatmentOutcomeTimePeriodId = '1')
				SET @StillOnTreatmentLast = 1
			ELSE IF (@Bucket = 'Still on treatment' and @TreatmentOutcomeTimePeriodId = '2')
				SET @StillOnTreatment12 = 1
			ELSE IF (@Bucket = 'Still on treatment' and @TreatmentOutcomeTimePeriodId = '3')
				SET @StillOnTreatment24 = 1
			ELSE IF (@Bucket = 'Still on treatment' and @TreatmentOutcomeTimePeriodId = '4')
				SET @StillOnTreatment36 = 1
			ELSE IF (@Bucket = 'Treatment stopped' and @TreatmentOutcomeTimePeriodId = '1')
				SET @TreatmentStoppedLast = 1
			ELSE IF (@Bucket = 'Treatment stopped' and @TreatmentOutcomeTimePeriodId = '2')
				SET @TreatmentStopped12 = 1
			ELSE IF (@Bucket = 'Treatment stopped' and @TreatmentOutcomeTimePeriodId = '3')
				SET @TreatmentStopped24 = 1
			ELSE IF (@Bucket = 'Treatment stopped' and @TreatmentOutcomeTimePeriodId = '4')
				SET @TreatmentStopped36 = 1
			ELSE IF (@Bucket = 'Not evaluated' and @TreatmentOutcomeTimePeriodId = '1')
				SET @NotEvaluatedLast = 1
			ELSE IF (@Bucket = 'Not evaluated' and @TreatmentOutcomeTimePeriodId = '2')
				SET @NotEvaluated12 = 1
			ELSE IF (@Bucket = 'Not evaluated' and @TreatmentOutcomeTimePeriodId = '3')
				SET @NotEvaluated24 = 1
			ELSE IF (@Bucket = 'Not evaluated' and @TreatmentOutcomeTimePeriodId = '4')
				SET @NotEvaluated36 = 1
			ELSE IF (@Bucket = 'Unknown' and @TreatmentOutcomeTimePeriodId = '1')
				SET @UnknownLast = 1
			ELSE IF (@Bucket = 'Unknown' and @TreatmentOutcomeTimePeriodId = '2')
				SET @Unknown12 = 1
			ELSE IF (@Bucket = 'Unknown' and @TreatmentOutcomeTimePeriodId = '3')
				SET @Unknown24 = 1
			ELSE IF (@Bucket = 'Unknown' and @TreatmentOutcomeTimePeriodId = '4')
				SET @Unknown36 = 1
			ELSE IF (@Bucket = 'Table total' and @TreatmentOutcomeTimePeriodId = '1')
				SET @TableTotalLast = 1
			ELSE IF (@Bucket = 'Table total' and @TreatmentOutcomeTimePeriodId = '2')
				SET @TableTotal12 = 1
			ELSE IF (@Bucket = 'Table total' and @TreatmentOutcomeTimePeriodId = '3')
				SET @TableTotal24 = 1
			ELSE IF (@Bucket = 'Table total' and @TreatmentOutcomeTimePeriodId = '4')
				SET @TableTotal36 = 1

			DECLARE @ReusableNotification ReusableNotificationType

			INSERT INTO @ReusableNotification 
			SELECT n.*
			FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n  -- This filters the records by regional PHEC permissions!
				INNER JOIN dbo.DrugResistanceProfile d ON d.DrugResistanceProfile = n.DrugResistanceProfile
				INNER JOIN dbo.OutcomeSummary o ON o.NotificationId = n.NotificationId			
			WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
				AND (((@ServiceName IS NULL OR @Region IS NULL) OR @ServiceName <> 'All') OR n.TreatmentPhec = @Region)
				AND (((@LocalAuthority IS NULL OR @Region IS NULL) OR @LocalAuthority <> 'All') OR n.ResidencePhec = @Region)
				AND ((@ServiceName IS NULL OR @ServiceName = 'All') OR 
					n.[Service] in (select value from STRING_SPLIT(@ServiceName, ',')) or
				--n.[Service] = @ServiceName or 
							(@serviceName = 'Blank' and service is null and n.ResidencePhec = @region and n.treatmentphec is null))
				AND ((@LocalAuthority IS NULL OR @LocalAuthority = 'All') OR n.LocalAuthority = @LocalAuthority)
				AND (@DrugResistanceProfile IS NULL OR n.DrugResistanceProfile = @DrugResistanceProfile)	
				AND (@TreatmentLast IS NULL OR o.TreatmentCompletedLastOutcome = @TreatmentLast)
				AND (@Treatment12 IS NULL OR o.TreatmentCompleted12Month = @Treatment12)
				AND (@Treatment24 IS NULL OR o.TreatmentCompleted24Month = @Treatment24)
				AND (@Treatment36 IS NULL OR o.TreatmentCompleted36Month = @Treatment36)
				AND (@DiedLast IS NULL OR o.DiedLastOutcome  = @DiedLast)
				AND (@Died12 IS NULL OR o.Died12Month  = @Died12)
				AND (@Died24 IS NULL OR o.Died24Month  = @Died24)
				AND (@Died36 IS NULL OR o.Died36Month  = @Died36)
				AND (@LostToFollowUpLast IS NULL OR o.LostToFollowUpLastOutcome  = @LostToFollowUpLast)
				AND (@LostToFollowUp12 IS NULL OR o.LostToFollowUp12Month  = @LostToFollowUp12)
				AND (@LostToFollowUp24 IS NULL OR o.LostToFollowUp24Month  = @LostToFollowUp24)
				AND (@LostToFollowUp36 IS NULL OR o.LostToFollowUp36Month  = @LostToFollowUp36)
				AND (@StillOnTreatmentLast IS NULL OR o.StillOnTreatmentLastOutcome  = @StillOnTreatmentLast)
				AND (@StillOnTreatment12 IS NULL OR o.StillOnTreatment12Month  = @StillOnTreatment12)
				AND (@StillOnTreatment24 IS NULL OR o.StillOnTreatment24Month  = @StillOnTreatment24)
				AND (@StillOnTreatment36 IS NULL OR o.StillOnTreatment36Month  = @StillOnTreatment36)
				AND (@TreatmentStoppedLast IS NULL OR o.TreatmentStoppedLastOutcome = @TreatmentStoppedLast)
				AND (@TreatmentStopped12 IS NULL OR o.TreatmentStopped12Month = @TreatmentStopped12)
				AND (@TreatmentStopped24 IS NULL OR o.TreatmentStopped24Month = @TreatmentStopped24)
				AND (@TreatmentStopped36 IS NULL OR o.TreatmentStopped36Month = @TreatmentStopped36)
				AND (@NotEvaluatedLast IS NULL OR o.NotEvaluatedLastOutcome  = @NotEvaluatedLast)
				AND (@NotEvaluated12 IS NULL OR o.NotEvaluated12Month  = @NotEvaluated12)
				AND (@NotEvaluated24 IS NULL OR o.NotEvaluated24Month  = @NotEvaluated24)
				AND (@NotEvaluated36 IS NULL OR o.NotEvaluated36Month  = @NotEvaluated36)
				AND (@UnknownLast IS NULL OR o.UnknownLastOutcome  = @UnknownLast)
				AND (@Unknown12 IS NULL OR o.Unknown12Month  = @Unknown12)
				AND (@Unknown24 IS NULL OR o.Unknown24Month  = @Unknown24)
				AND (@Unknown36 IS NULL OR o.Unknown36Month  = @Unknown36)
				AND (@TableTotalLast IS NULL OR (o.TreatmentCompletedLastOutcome  > 0 
											OR o.TreatmentCompleted12Month  > 0 
											OR o.TreatmentCompleted24Month  > 0 
											OR o.TreatmentCompleted36Month  > 0 
											OR o.DiedLastOutcome > 0 
											OR o.Died12Month > 0 
											OR o.Died24Month > 0 
											OR o.Died36Month > 0 
											OR o.LostToFollowUpLastOutcome > 0 
											OR o.LostToFollowUp12Month > 0 
											OR o.LostToFollowUp24Month > 0 
											OR o.LostToFollowUp36Month > 0 
											OR o.StillOnTreatmentLastOutcome > 0 
											OR o.StillOnTreatment12Month > 0 
											OR o.StillOnTreatment24Month > 0 
											OR o.StillOnTreatment36Month > 0 
											OR o.TreatmentStoppedLastOutcome > 0 
											OR o.TreatmentStopped12Month > 0 
											OR o.TreatmentStopped24Month > 0 
											OR o.TreatmentStopped36Month > 0 
											OR o.NotEvaluatedLastOutcome > 0
											OR o.NotEvaluated12Month > 0
											OR o.NotEvaluated24Month > 0
											OR o.NotEvaluated36Month > 0
											OR o.UnknownLastOutcome > 0 
											OR o.Unknown12Month > 0 
											OR o.Unknown24Month > 0 
											OR o.Unknown36Month > 0 ))				
				AND (@TableTotal12 IS NULL OR (o.TreatmentCompleted12Month  > 0 
											OR o.Died12Month > 0 
											OR o.LostToFollowUp12Month > 0 
											OR o.StillOnTreatment12Month > 0 
											OR o.TreatmentStopped12Month > 0 
											OR o.NotEvaluated12Month > 0
											OR o.Unknown12Month > 0))
				AND (@TableTotal24 IS NULL OR (o.TreatmentCompleted24Month  > 0 
											OR o.Died24Month > 0 
											OR o.LostToFollowUp24Month > 0 
											OR o.StillOnTreatment24Month > 0 
											OR o.TreatmentStopped24Month > 0 
											OR o.NotEvaluated24Month > 0
											OR o.Unknown24Month > 0))
				AND (@TableTotal36 IS NULL OR (o.TreatmentCompleted36Month  > 0 
											OR o.Died36Month > 0 
											OR o.LostToFollowUp36Month > 0 
											OR o.StillOnTreatment36Month > 0 
											OR o.TreatmentStopped36Month > 0 
											OR o.NotEvaluated36Month > 0
											OR o.Unknown36Month > 0))
					
			SELECT
				-- Primary key
				n.NotificationId                                       AS 'ID',

				-- Demographics
				n.EtsId                                                AS 'ETS ID',
				n.LtbrId											   AS 'LTBR ID',
				dbo.ufnFormatDateConsistently(n.NotificationDate)      AS 'Notification date',
				n.CaseManager                                          AS 'Case manager',
				n.Consultant                                           AS 'Consultant',
				n.Hospital                                             AS 'Hospital',
				n.[Service]                                            AS 'Service',
				n.NhsNumber                                            AS 'NHS Number',
				n.Forename                                             AS 'Forename',
				n.Surname                                              AS 'Surname',
				dbo.ufnFormatDateConsistently(n.DateOfBirth)           AS 'Date of birth',
				n.Age                                                  AS 'Age',
				n.Sex                                                  AS 'Sex',
				n.UkBorn                                               AS 'UK born',
				n.EthnicGroup                                          AS 'Ethnic group',
				n.BirthCountry                                         AS 'Birth country',
				n.UkEntryYear                                          AS 'UK entry year',
				n.Postcode                                             AS 'Postcode',
				n.NoFixedAbode                                         AS 'No fixed abode',

				-- Geographies
				n.LocalAuthority                                       AS 'Local Authority',
				n.LocalAuthorityCode                                   AS 'Local Authority Code',
				n.ResidencePhec                                        AS 'Residence PHEC',
				n.TreatmentPhec                                        AS 'Treatment PHEC',

				-- Treatment
				n.PostMortemDiagnosis                                  AS 'Post-mortem diagnosis',
				n.DidNotStartTreatment                                 AS 'Did not start treatment',
				n.ShortCourse                                          AS 'Short course',
				n.MdrTreatment                                         AS 'MDR treatment',
				dbo.ufnFormatDateConsistently(n.MdrTreatmentDate)      AS 'MDR treatment date',
				n.TreatmentOutcome12months                             AS 'Treatment outcome 12 months',
				n.TreatmentOutcome24months                             AS 'Treatment outcome 24 months',
				n.TreatmentOutcome36months                             AS 'Treatment outcome 36 months',
				n.LastRecordedTreatmentOutcome                         AS 'Last recorded treatment outcome',
				dbo.ufnFormatDateConsistently(n.DateOfDeath)           AS 'Date of death',
				dbo.ufnFormatDateConsistently(n.TreatmentEndDate)      AS 'Treatment end date',

				-- Culture & Resistance
				n.NoSampleTaken                                        AS 'No sample taken',
				n.CulturePositive                                      AS 'Culture positive',
				n.Species                                              AS 'Species',
				dbo.ufnFormatDateConsistently(n.EarliestSpecimenDate)  AS 'Earliest specimen date',
				n.DrugResistanceProfile                                AS 'Drug resistance profile',
				n.INH                                                  AS 'INH',
				n.RIF                                                  AS 'RIF',
				n.EMB	                                               AS 'EMB',
				n.PZA                                                  AS 'PZA',
				n.MDR                                                  AS 'MDR',
				n.XDR                                                  AS 'XDR',
			
				-- Clinical Details
				dbo.ufnFormatDateConsistently(n.SymptomOnsetDate)      AS 'Symptom onset date',
				dbo.ufnFormatDateConsistently(n.PresentedDate)         AS 'Presented date',
				n.OnsetToPresentationDays                              AS 'Onset to presentation days',
				dbo.ufnFormatDateConsistently(n.DiagnosisDate)         AS 'Diagnosis date',
				n.PresentationToDiagnosisDays                          AS 'Presentation to diagnosis days',
				dbo.ufnFormatDateConsistently(n.StartOfTreatmentDate)  AS 'Start of treatment date',
				n.DiagnosisToTreatmentDays                             AS 'Diagnosis to treatment days',
				n.OnsetToTreatmentDays                                 AS 'Onset to treatment days',
				n.HivTestOffered                                       AS 'HIV test offered',
				n.SiteOfDisease                                        AS 'Site of disease',

				-- Risk Factors
				n.AnySocialRiskFactor                                  AS 'Any social risk factor',
				n.AlcoholMisuse		                                   AS 'Alcohol misuse',
				n.DrugMisuse 							               AS 'Drug misuse',
				n.Homeless								               AS 'Homeless',
				n.Prison								               AS 'Prison'
			FROM @ReusableNotification n
			ORDER BY n.NotificationDate DESC

			/*
				-- Debugging
				SELECT @NotificationDateFrom AS '@NotificationDateFrom',
					@NotificationDateTo AS '@NotificationDateTo',
					@NotificationYearFrom AS '@NotificationYearFrom',
			        @NotificationMonthFrom	AS '@NotificationMonthFrom',
			        @NotificationYearTo	AS '@NotificationYearTo',
			        @NotificationMonthTo AS '@NotificationMonthTo',
			        @Region	AS '@Region',
			        @DrugResistanceProfile AS '@DrugResistanceProfile',
			        @LocalAuthority	AS '@LocalAuthority',
			        @ServiceName AS '@ServiceName',
			        @Bucket	AS '@Bucket'
			*/

			-- Write data to audit log
			EXEC dbo.uspAddToAudit 'Outcome Summary', @LoginGroups, @ReusableNotification
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
