/***************************************************************************************************
Desc:    This serves the "Boilerplate Line List", which returns every/most notification data point
         in detail, based on the user's permission & filtering preference. Every notification record
		 returned gets audited, whch means a log entry gets added for each user that views a notification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspBoilerplateLineList]
		(
			@NotificationYearFrom			INTEGER			=	-3,
			@NotificationMonthFrom			INTEGER			=	1,
			@NotificationYearTo				INTEGER			=	0,
			@NotificationMonthTo			INTEGER			=	1,
			@Region							VARCHAR(50)		=	NULL,
			@LocalAuthority					VARCHAR(50)		=	NULL,
			@ServiceName					VARCHAR(150)	=	NULL,
			@Bucket							VARCHAR(50)		=	NULL	
		)
AS
	SET NOCOUNT ON

	-- Debugging
	-- EXEC master..xp_logevent 60000, @ResidenceTreatment

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN

			/*
				-- DEBUGGING: The below variables are for faking parameter values for debugging purposes
				DECLARE @LoginGroups VARCHAR(500), @NotificationYearFrom INTEGER, @NotificationMonthFrom INTEGER, @NotificationYearTo INTEGER, @NotificationMonthTo INTEGER, @Region VARCHAR(50), @LocalAuthority VARCHAR(50), @ServiceName VARCHAR(150), @Bucket VARCHAR(50)
				SET @LoginGroups = '###Global.NIS.NTBS.LON###'
				SET @NotificationYearFrom =	-3
				SET @NotificationMonthFrom	= 1
				SET @NotificationYearTo	= 0
				SET @NotificationMonthTo = 1
				SET @Region	= 'London'
				SET @LocalAuthority	= 'Brent'
				SET @ServiceName = NULL
				SET @Bucket	= 'table total'
			*/

			DECLARE @NotificationYearTypeFrom	VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)

            DECLARE @NotificationYearTypeTo		VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)

			DECLARE @BoilerplateCalculation1 INT = NULL
			DECLARE @BoilerplateCalculation2 INT = NULL
			DECLARE @TableTotal INT = NULL

			IF (@Bucket = 'Boilerplate calculation 1')
				SET @BoilerplateCalculation1 = 1
			ELSE IF (@Bucket = 'Boilerplate calculation 2')
				SET @BoilerplateCalculation2 = 1
			ELSE IF (@Bucket = 'Table total')
				SET @TableTotal = 1
							
			DECLARE @ReusableNotification ReusableNotificationType

			INSERT INTO @ReusableNotification
				SELECT n.*
				FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n  -- This filters the records by regional PHEC permissions!

					INNER JOIN dbo.Boilerplate b ON b.NotificationId = n.NotificationId
			WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
				AND (((@ServiceName IS NULL OR @Region IS NULL) OR @ServiceName <> 'All') OR n.TreatmentPhec = @Region)
				AND (((@LocalAuthority IS NULL OR @Region IS NULL) OR @LocalAuthority <> 'All') OR n.ResidencePhec = @Region)
				AND ((@ServiceName IS NULL OR @ServiceName = 'All') OR n.[Service] = @ServiceName)
				AND ((@LocalAuthority IS NULL OR @LocalAuthority = 'All') OR n.LocalAuthority = @LocalAuthority)
				AND (@BoilerplateCalculation1 IS NULL OR b.BoilerplateCalculationNo1 = @BoilerplateCalculation1)	
				AND (@BoilerplateCalculation2 IS NULL OR b.BoilerplateCalculationNo2 = @BoilerplateCalculation2)
				AND (@TableTotal IS NULL OR (  b.BoilerplateCalculationNo1 = @TableTotal 
											OR b.BoilerplateCalculationNo2  = @TableTotal
											
											)
					)

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

			-- Write data to audit log
			EXEC dbo.uspAddToAudit 'Boilerplate', @LoginGroups, @ReusableNotification
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH