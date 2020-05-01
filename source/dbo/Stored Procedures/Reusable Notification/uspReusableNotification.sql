/***************************************************************************************************
Desc:    Give regional users the ReusableNotification recordset filtered by permissions, i.e. only
		 notifications in their region. This contains the superset of their region's 
		 treatment/residence notification records


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspReusableNotification] AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT

		-- Debugging
		-- EXEC master..xp_logevent 60000, @LoginGroups

		IF (@LoginGroups != '###')
		BEGIN
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
			FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n
			ORDER BY n.NotificationDate DESC
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
