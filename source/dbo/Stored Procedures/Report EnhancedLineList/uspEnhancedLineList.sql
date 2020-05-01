/***************************************************************************************************
Desc:    This serves the "Enhanced Line List", which returns every/most notification data point
         in detail, based on the user's permission & filtering preference. Every notification record
		 returned gets audited, whch means a log entry gets added for each user that views a notification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspEnhancedLineList]
	(
		@NotificationYearFrom	INTEGER			=	-3,
		@NotificationMonthFrom	INTEGER			=	1,
		@NotificationYearTo		INTEGER			=	0,
		@NotificationMonthTo	INTEGER			=	1,
		@ResidenceTreatment		TINYINT			=   1,
		@Region					VARCHAR(1000)	=	NULL,
		@AgeFrom				INTEGER			=	NULL,
		@AgeTo					INTEGER			=	NULL,
		@UKBorn					VARCHAR(3)		=	NULL,
		@SocialRiskFactors		INTEGER			=	NULL,
		@Comorbidities			INTEGER			=	NULL,
		@SiteOfDisease			VARCHAR(16)		=	NULL,	
		@DrugResistanceProfile	varchar(1000)	=	NULL,
		@Species				VARCHAR(25)		=	NULL,	
		@Service				varchar(5000)	=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT

		-- Debugging
		-- EXEC master..xp_logevent 60000, @LoginGroups

		IF (@LoginGroups != '###')
		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
			DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
			DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
			DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo) -- Move end date to last day of month

			DECLARE @SRF_Any				VARCHAR(3) = (CASE WHEN @SocialRiskFactors = 2 THEN 'No'
																WHEN @SocialRiskFactors = 3 THEN 'Yes' ELSE NULL END)
			DECLARE @SRF_Alcohol_Misuse		VARCHAR(3) = (CASE WHEN @SocialRiskFactors = 4 THEN 'Yes' ELSE NULL END)	
			DECLARE @SRF_Drug_Misuse		VARCHAR(3) = (CASE WHEN @SocialRiskFactors = 5 THEN 'Yes' ELSE NULL END)
			DECLARE @SRF_Homeless			VARCHAR(3) = (CASE WHEN @SocialRiskFactors = 6 THEN 'Yes' ELSE NULL END)
			DECLARE @SRF_Prison				VARCHAR(3) = (CASE WHEN @SocialRiskFactors = 7 THEN 'Yes' ELSE NULL END)

			DECLARE @CRF_None				VARCHAR(3) = (CASE WHEN @Comorbidities = 2 THEN 'Yes' ELSE NULL END)	
			DECLARE @CRF_Chronic_Liver		VARCHAR(3) = (CASE WHEN @Comorbidities = 3 THEN 'Yes' ELSE NULL END)	
			DECLARE @CRF_Chronic_Renal		VARCHAR(3) = (CASE WHEN @Comorbidities = 4 THEN 'Yes' ELSE NULL END)
			DECLARE @CRF_Diabetes			VARCHAR(3) = (CASE WHEN @Comorbidities = 5 THEN 'Yes' ELSE NULL END)
			DECLARE @CRF_Hepatitis_B		VARCHAR(3) = (CASE WHEN @Comorbidities = 6 THEN 'Yes' ELSE NULL END)
			DECLARE @CRF_Hepatitis_C		VARCHAR(3) = (CASE WHEN @Comorbidities = 7 THEN 'Yes' ELSE NULL END)
			DECLARE @CRF_Smoking			VARCHAR(3) = (CASE WHEN @Comorbidities = 8 THEN 'Yes' ELSE NULL END)

			-- If value is All then set to null  = null in where clause, otherwise set to filter value
			DECLARE @BornInUK				VARCHAR(3) = (CASE WHEN @UKBorn = 'All' THEN NULL ELSE @UKBorn END)
			DECLARE @SOD					VARCHAR(16) = (CASE WHEN @SiteOfDisease = 'All' THEN NULL ELSE @SiteOfDisease END)
			--DECLARE @DRP					VARCHAR(30) = (CASE WHEN @DrugResistanceProfile = 'All' THEN NULL ELSE @DrugResistanceProfile END)
			DECLARE @SpeciesValue			VARCHAR(25) = (CASE WHEN @Species = 'All' THEN NULL ELSE @Species END)
			set @Service					= CASE
												WHEN
													-- the number of services provided into the parameter
													LEN(@Service) - LEN(REPLACE(@Service, ',', '')) +1 
													-- the number of services that exist in the provieded regions
													= (SELECT COUNT(*) FROM TB_Service WHERE PhecName IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')))
													THEN'All' 
												ELSE @Service
											END
			
			DECLARE @ReusableNotification ReusableNotificationType

			If (@Service = 'All')
			Begin

			INSERT INTO @ReusableNotification
				SELECT n.*
				FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n  -- This filters the records by regional PHEC permissions!
				WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					AND (
							(
									@ResidenceTreatment = 1 AND
									(n.TreatmentPhec IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')) OR n.ResidencePhec IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')))
							) OR (
									@ResidenceTreatment = 2 AND
									n.TreatmentPhec IN (SELECT VALUE FROM STRING_SPLIT(@Region, ','))
							) OR (
									@ResidenceTreatment = 3 AND
									n.ResidencePhec IN (SELECT VALUE FROM STRING_SPLIT(@Region, ','))
							)
					)
					AND (@AgeFrom IS NULL OR n.Age IS NULL OR n.Age >= @AgeFrom)
					AND (@AgeTo IS NULL OR n.Age IS NULL OR n.Age <= @AgeTo)
					AND (@BornInUK IS NULL OR n.UkBorn = @BornInUK)
					AND (@SOD IS NULL OR n.SiteOfDisease = @SOD)
					AND n.DrugResistanceProfile in  (select value from STRING_SPLIT(@DrugResistanceProfile, ','))
					AND (@SpeciesValue IS NULL OR n.Species = @SpeciesValue)
					--SocialRiskFactors
					AND (@SRF_Any IS NULL OR n.AnySocialRiskFactor = @SRF_Any)
					AND (@SRF_Alcohol_Misuse IS NULL OR n.AlcoholMisuse = @SRF_Alcohol_Misuse)
					AND (@SRF_Drug_Misuse IS NULL OR n.DrugMisuse = @SRF_Drug_Misuse)
					AND (@SRF_Homeless IS NULL OR n.Homeless = @SRF_Homeless)
					AND (@SRF_Prison IS NULL OR n.Prison = @SRF_Prison)
					--ClinicalRiskFactors
					AND (@CRF_None IS NULL OR n.ChronicLiverDisease = 'No' AND n.ChronicRenalDisease = 'No' AND n.Diabetes = 'No' AND n.HepatitisB = 'No' AND n.HepatitisC = 'No' AND n.ImmunoSuppression = 'No' AND n.CurrentSmoker = 'No')
					AND (@CRF_Chronic_Liver IS NULL OR n.ChronicLiverDisease = @CRF_Chronic_Liver) 
					AND (@CRF_Chronic_Renal IS NULL OR n.ChronicRenalDisease = @CRF_Chronic_Renal)
					AND (@CRF_Diabetes IS NULL OR n.Diabetes = @CRF_Diabetes)
					AND (@CRF_Hepatitis_B IS NULL OR n.HepatitisB = @CRF_Hepatitis_B)
					AND (@CRF_Hepatitis_C IS NULL OR n.HepatitisC = @CRF_Hepatitis_C)
					AND (@CRF_Smoking IS NULL OR n.CurrentSmoker = @CRF_Smoking)
				End

			If (@Service <> 'All')
			Begin

			INSERT INTO @ReusableNotification
				SELECT n.*
				FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n  -- This filters the records by regional PHEC permissions!
				inner join TB_Service s on s.TB_Service_Name = n.Service
				WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					AND (
							(
									@ResidenceTreatment = 1 AND
									(n.TreatmentPhec IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')) OR n.ResidencePhec IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')))
							) OR (
									@ResidenceTreatment = 2 AND
									n.TreatmentPhec IN (SELECT VALUE FROM STRING_SPLIT(@Region, ','))
							) OR (
									@ResidenceTreatment = 3 AND
									n.ResidencePhec IN (SELECT VALUE FROM STRING_SPLIT(@Region, ','))
							)
					)
					and Serviceid in (select value from STRING_SPLIT(@Service, ','))
					AND (@AgeFrom IS NULL OR n.Age IS NULL OR n.Age >= @AgeFrom)
					AND (@AgeTo IS NULL OR n.Age IS NULL OR n.Age <= @AgeTo)
					AND (@BornInUK IS NULL OR n.UkBorn = @BornInUK)
					AND (@SOD IS NULL OR n.SiteOfDisease = @SOD)
					AND n.DrugResistanceProfile in  (select value from STRING_SPLIT(@DrugResistanceProfile, ','))
					AND (@SpeciesValue IS NULL OR n.Species = @SpeciesValue)
					--SocialRiskFactors
					AND (@SRF_Any IS NULL OR n.AnySocialRiskFactor = @SRF_Any)
					AND (@SRF_Alcohol_Misuse IS NULL OR n.AlcoholMisuse = @SRF_Alcohol_Misuse)
					AND (@SRF_Drug_Misuse IS NULL OR n.DrugMisuse = @SRF_Drug_Misuse)
					AND (@SRF_Homeless IS NULL OR n.Homeless = @SRF_Homeless)
					AND (@SRF_Prison IS NULL OR n.Prison = @SRF_Prison)
					--ClinicalRiskFactors
					AND (@CRF_None IS NULL OR n.ChronicLiverDisease = 'No' AND n.ChronicRenalDisease = 'No' AND n.Diabetes = 'No' AND n.HepatitisB = 'No' AND n.HepatitisC = 'No' AND n.ImmunoSuppression = 'No' AND n.CurrentSmoker = 'No')
					AND (@CRF_Chronic_Liver IS NULL OR n.ChronicLiverDisease = @CRF_Chronic_Liver) 
					AND (@CRF_Chronic_Renal IS NULL OR n.ChronicRenalDisease = @CRF_Chronic_Renal)
					AND (@CRF_Diabetes IS NULL OR n.Diabetes = @CRF_Diabetes)
					AND (@CRF_Hepatitis_B IS NULL OR n.HepatitisB = @CRF_Hepatitis_B)
					AND (@CRF_Hepatitis_C IS NULL OR n.HepatitisC = @CRF_Hepatitis_C)
					AND (@CRF_Smoking IS NULL OR n.CurrentSmoker = @CRF_Smoking)

				End

			-- Return data to client app
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
				n.AdultContactsIdentified                              AS 'Adult contacts identified',
				n.ChildContactsIdentified	                           AS 'Child contacts identified',
				n.TotalContactsIdentified	                           AS 'Total contacts identified',
				n.AdultContactsAssessed                                AS 'Adult contacts screened',
				n.ChildContactsAssessed                                AS 'Child contacts screened',
				n.TotalContactsAssessed                                AS 'Total contacts screened',
				n.AdultContactsActiveTB                                AS 'Adult contacts with active TB',
				n.ChildContactsActiveTB                                AS 'Child contacts with active TB',
				n.TotalContactsActiveTB                                AS 'Total contacts with active TB',
				n.AdultContactsLTBI                                    AS 'Adult contacts with LTBI',
				n.ChildContactsLTBI                                    AS 'Child contacts with LTBI',
				n.TotalContactsLTBI                                    AS 'Total contacts with LTBI',
				n.AdultContactsLTBITreat                               AS 'Adult LTBI contacts started LTBI treatment',
				n.ChildContactsLTBITreat                               AS 'Child LTBI contacts started LTBI treatment',
				n.TotalContactsLTBITreat                               AS 'Total LTBI  contacts started LTBI treatment',
				n.AdultContactsLTBITreatComplete                       AS 'Adult LTBI contacts completed LTBI treatment',
				n.ChildContactsLTBITreatComplete                       AS 'Child LTBI contacts completed LTBI treatment',
				n.TotalContactsLTBITreatComplete                       AS 'Total LTBI contacts completed LTBI treatment',
				n.PreviouslyDiagnosed                                  AS 'Previously diagnosed',
				n.YearsSinceDiagnosis                                  AS 'Years since diagnosis',
				n.PreviouslyTreated                                    AS 'Previously treated',
				n.TreatmentInUk                                        AS 'Treatment in UK',
				n.PreviousId                                           AS 'Previous ID',
				n.BcgVaccinated                                        AS 'BCG vaccinated',

				-- Risk Factors
				n.AnySocialRiskFactor                                  AS 'Any social risk factor',
				n.AlcoholMisuse                                        AS 'Alcohol misuse',
				n.DrugMisuse 							               AS 'Drug misuse',
				n.CurrentDrugMisuse                                    AS 'Current drug misuse',
				n.DrugMisuseInLast5Years                               AS 'Drug misuse in last 5 years',
				n.DrugMisuseMoreThan5YearsAgo                          AS 'Drug misuse more than 5 years ago',
				n.Homeless								               AS 'Homeless',
				n.CurrentlyHomeless                                    AS 'Currently homeless',
				n.HomelessInLast5Years                                 AS 'Homeless in last 5 years',
				n.HomelessMoreThan5YearsAgo                            AS 'Homeless more than 5 years ago',
				n.Prison								               AS 'Prison',
				n.CurrentlyInPrisonOrInPrisonWhenFirstSeen             AS 'Currently in prison or in prison when first seen',
				n.InPrisonInLast5Years                                 AS 'In prison in last 5 years',
				n.InPrisonMoreThan5YearsAgo                            AS 'In prison more than 5 years ago',
				n.TravelledOutsideUk                                   AS 'Travelled outside UK',
				n.ToHowManyCountries                                   AS 'To how many countries',
				n.TravelCountry1                                       AS 'Travel country 1',
				n.MonthsTravelled1                                     AS 'Months travelled 1',
				n.TravelCountry2                                       AS 'Travel country 2',
				n.MonthsTravelled2                                     AS 'Months travelled 2',
				n.TravelCountry3                                       AS 'Travel country 3',
				n.MonthsTravelled3                                     AS 'Months travelled 3',
				n.ReceivedVisitors                                     AS 'Received visitors',
				n.FromHowManyCountries                                 AS 'From how many countries',
				n.VisitorCountry1                                      AS 'Visitor country 1',
				n.DaysVisitorsStayed1                                  AS 'Days visitors stayed 1',
				n.VisitorCountry2                                      AS 'Visitor country 2',
				n.DaysVisitorsStayed2                                  AS 'Days visitors stayed 2',
				n.VisitorCountry3                                      AS 'Visitor country 3',
				n.DaysVisitorsStayed3                                  AS 'Days visitors stayed 3',
				n.Diabetes                                             AS 'Diabetes',
				n.HepatitisB                                           AS 'Hepatitis B',
				n.HepatitisC                                           AS 'Hepatitis C',
				n.ChronicLiverDisease                                  AS 'Chronic liver disease',
				n.ChronicRenalDisease                                  AS 'Chronic renal disease',
				n.ImmunoSuppression                                    AS 'Immunosuppression',
				n.BiologicalTherapy                                    AS 'Biological therapy',
				n.Transplantation                                      AS 'Transplantation',
				n.OtherImmunoSuppression                               AS 'Other immunosuppression',
				n.CurrentSmoker                                        AS 'Current smoker',
			
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
				n.EMB                                                  AS 'EMB',
				n.PZA                                                  AS 'PZA',
				n.MDR                                                  AS 'MDR',
				n.XDR                                                  AS 'XDR'
			FROM @ReusableNotification n
			ORDER BY n.NotificationDate DESC

			-- Write data to audit log
			EXEC dbo.uspAddToAudit 'Enhanced Line List', @LoginGroups, @ReusableNotification
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
GO