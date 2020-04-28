/***************************************************************************************************
Desc:    This serves the "Culture And Resistance Line List", which returns every/most notification data point
         in detail, based on the user's permission & filtering preference. Every notification record
		 returned gets audited, whch means a log entry gets added for each user that views a notification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspCultureResistanceLineList]
(
		@NotificationYearFrom	INTEGER			=	-3,
		@NotificationMonthFrom	INTEGER			=	1,
		@NotificationYearTo		INTEGER			=	0,
		@NotificationMonthTo	INTEGER			=	1,
	--	@ResidenceTreatment		TINYINT			=   3,
		@Region					VARCHAR(50)		=	NULL,
		@Service				VARCHAR(5000)	=	NULL,
		@LocalAuthority					VARCHAR(50)		=	NULL,
		@SiteOfDisease			VARCHAR(16)		=	NULL,	
		@Bucket					VARCHAR(50)		=	NULL	
	)
AS
	SET NOCOUNT ON

	-- Debugging
	-- EXEC master..xp_logevent 60000, @Region

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN
			/*
				-- Debugging
				DECLARE @NotificationDateFrom DATE = '2016-01-01'
				DECLARE @NotificationDateTo DATE = '2019-01-31'
				DECLARE @ResidenceTreatment TINYINT = 1
				-- DECLARE @SOD VARCHAR(16) = NULL
				DECLARE @Region VARCHAR(50) = 'London'
				DECLARE @Bucket VARCHAR(50) = 'Culture positive cases'
				DECLARE @LoginGroups VARCHAR(50) = '###Global.NIS.NTBS.LON###'
			*/

			DECLARE @NotificationYearTypeFrom	VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
            DECLARE @NotificationYearTypeTo		VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)

			-- If value is All then set to null  = null in where clause, otherwise set to filter value
			DECLARE @SOD						VARCHAR(16) = (CASE WHEN @SiteOfDisease = 'All' THEN NULL ELSE @SiteOfDisease END)

			DECLARE @CulturePositiveCases TINYINT = NULL
			DECLARE @NonCulturePositiveCases TINYINT = NULL
			DECLARE @Table1Total TINYINT = NULL
			DECLARE @SensitiveToAll4FirstLineDrugs TINYINT = NULL
			DECLARE @InhRes TINYINT = NULL
			DECLARE @Other TINYINT = NULL
			DECLARE @MdrRr TINYINT = NULL
			DECLARE @Xdr TINYINT = NULL
			DECLARE @IncompleteDrugResistanceProfile TINYINT = NULL
			DECLARE @Table2Total TINYINT = NULL

			IF (@Bucket = 'Culture positive cases')
				SET @CulturePositiveCases = 1
			ELSE IF (@Bucket = 'Non-culture positive cases')
				SET @NonCulturePositiveCases = 1
			ELSE IF (@Bucket = 'Table 1 total')
				SET @Table1Total = 1
			ELSE IF (@Bucket = 'Sensitive to all 4 first line drugs')
				SET @SensitiveToAll4FirstLineDrugs = 1
			ELSE IF (@Bucket = 'INH-RES')
				SET @InhRes = 1
			ELSE IF (@Bucket = 'Other')
				SET @Other = 1
			ELSE IF (@Bucket = 'MDR/RR')
				SET @MdrRr = 1
			ELSE IF (@Bucket = 'XDR')
				SET @Xdr = 1
			ELSE IF (@Bucket = 'Incomplete drug resistance profile')
				SET @IncompleteDrugResistanceProfile = 1
			ELSE IF (@Bucket = 'Table 2 total')
				SET @Table2Total = 1
			ELSE 
				RAISERROR ('The @Bucket passed is invalid', 16, 1) WITH NOWAIT

			DECLARE @ReusableNotification ReusableNotificationType

			INSERT INTO @ReusableNotification
				SELECT n.*
				FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n  -- This filters the records by regional PHEC permissions!
					INNER JOIN dbo.CultureResistance c ON c.NotificationId = n.NotificationId
				WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
				AND (((@Service IS NULL OR @Region IS NULL) OR @Service <> 'All') OR n.TreatmentPhec = @Region)
				AND (((@LocalAuthority IS NULL OR @Region IS NULL) OR @LocalAuthority <> 'All') OR n.ResidencePhec = @Region)
				AND ((@Service IS NULL OR @Service = 'All') OR 
					n.[Service] in (select value from STRING_SPLIT(@Service, ',')) or
					(@Service = 'Blank' and Service is null and n.ResidencePhec = @region and n.TreatmentPhec is null))
				AND ((@LocalAuthority IS NULL OR @LocalAuthority = 'All') OR n.LocalAuthority = @LocalAuthority)
					AND (@SOD IS NULL OR n.SiteOfDisease = @SOD)
					-- Buckets			
					AND (@CulturePositiveCases IS NULL OR c.CulturePositiveCases = @CulturePositiveCases)
					AND (@NonCulturePositiveCases IS NULL OR c.NonCulturePositiveCases = @NonCulturePositiveCases)
					AND (@Table1Total IS NULL OR (c.CulturePositiveCases > 0 OR c.NonCulturePositiveCases > 0))
					AND (@SensitiveToAll4FirstLineDrugs IS NULL OR c.SensitiveToAll4FirstLineDrugs = @SensitiveToAll4FirstLineDrugs)
					AND (@InhRes IS NULL OR c.InhRes = @InhRes)
					AND (@Other IS NULL OR c.Other = @Other)
					AND (@MdrRr IS NULL OR c.MdrRr = @MdrRr)
					AND (@Xdr IS NULL OR c.Xdr = @Xdr)
					AND (@IncompleteDrugResistanceProfile IS NULL OR c.IncompleteDrugResistanceProfile = @IncompleteDrugResistanceProfile)
					AND (@Table2Total IS NULL OR (c.SensitiveToAll4FirstLineDrugs > 0 OR c.InhRes > 0 OR c.Other > 0 OR c.MdrRr > 0 OR c.Xdr > 0 OR c.IncompleteDrugResistanceProfile> 0))

			SELECT
				-- Primary key
				n.NotificationId                                       AS 'ID',

				-- Demographics
				n.EtsId                                                AS 'ETS ID',
				n.LtbrId                                               AS 'LTBR ID',
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
				n.Ukborn                                               AS 'UK born',
				n.EthnicGroup                                          AS 'Ethnic group',
				n.BirthCountry                                         AS 'Birth country',
				n.UkEntryYear                                          AS 'UK entry year',
				n.Postcode                                             AS 'Postcode',
				n.NoFixedAbode                                         AS 'No fixed abode',

				-- Culture & Resistance
				n.NoSampleTaken                                        AS 'No sample taken',
				n.CulturePositive                                      AS 'Culture positive',
				n.Species                                              AS 'Species',
				dbo.ufnFormatDateConsistently(n.EarliestSpecimenDate)  AS 'Earliest specimen date',
				n.DrugResistanceProfile                                AS 'Drug resistance profile',
				n.INH                                                  AS 'INH',
				n.RIF                                                  AS 'RIF',
				n.EMB                                                  AS 'EMB',
				n.PZA                                                  AS 'PZA',
				n.MDR                                                  AS 'MDR',
				n.XDR                                                  AS 'XDR',

				-- Geographies
				n.LocalAuthority                                       AS 'Local Authority',
				n.LocalAuthorityCode                                   AS 'Local Authority Code',
				n.ResidencePhec                                        AS 'Residence PHEC',
				n.TreatmentPhec                                        AS 'Treatment PHEC',

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
				n.AlcoholMisuse                                        AS 'Alcohol misuse',
				n.DrugMisuse 							               AS 'Drug misuse',
				n.Homeless								               AS 'Homeless',
				n.Prison								               AS 'Prison',
			
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
				dbo.ufnFormatDateConsistently(n.TreatmentEndDate)      AS 'Treatment end date'
			FROM @ReusableNotification n
			ORDER BY n.NotificationDate DESC

			-- Write data to audit log
			EXEC dbo.uspAddToAudit 'Culture And Resistance', @LoginGroups, @ReusableNotification
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH