/***************************************************************************************************
Desc:    This pre-calculates apprx 90 reusable notification data points over-night that each report 
         can report from. Please DO NOT report from ETS directly, if the data can also be found here!
		 If you write an aggregate proc, you can query join up on this Reusablenotification table directly.
		 If you write a list list proc, please query ufnAuthorizedReusableNotification() instead, which
		 will apply permission restrictions to the notification records you report on.


         
**************************************************************************************************/

Create PROCEDURE [dbo].[uspGenerateReusableNotification_ETS] AS
	SET NOCOUNT ON

	BEGIN TRY
		-- Populate table to remove spaces from postcodes
		EXEC dbo.uspGenerateReusablePostcodeLookup

		--prep the lab results
		DELETE FROM [dbo].[StandardisedETSLaboratoryResult]

		INSERT INTO [dbo].[StandardisedETSLaboratoryResult](NotificationId, Id, OpieId)
			SELECT n.LegacyId AS NotificationId
				,lr.Id
				,lr.OpieId
			FROM [$(ETS)].[dbo].[LaboratoryResult] lr
			LEFT JOIN [$(ETS)].dbo.[Notification] n ON n.Id = lr.NotificationId
				WHERE lr.AuditDelete IS NULL

		-- Reset
		DELETE FROM dbo.ReusableNotification_ETS

		INSERT INTO dbo.ReusableNotification_ETS
			SELECT
				-- Primary key
				n.LegacyId                                                  AS NotificationId,
				NULL														AS NtbsId,
				-- Demographics
				n.LegacyId                                                  AS EtsId,
				'ETS'														AS SourceSystem,
				dbo.ufnNormalizeLtbrId(n.AuditMigrateId)                    AS LtbrId,
				CONVERT(DATE, n.NotificationDate)                           AS NotificationDate,
				s.Forename + ' ' + s.Surname                                AS CaseManager,
				n.PatientConsultant                                         AS Consultant,
				CONVERT(VARCHAR(36), h.Id)                                  AS HospitalId,
				h.Name                                                      AS Hospital,
				NULL														AS [TBServiceCode],
				NULL                                                        AS [Service],
				p.NhsNumber                                                 AS NhsNumber,
				p.Forename                                                  AS Forename,
				p.Surname                                                   AS Surname,
				CONVERT(DATE, p.DateOfBirth)                                AS DateOfBirth,
				dbo.ufnGetAgefrom(p.DateOfBirth,n.NotificationDate)			As Age,
				dbo.ufnSex(p.Sex)                                           AS Sex,
				dbo.ufnYesNoUnknown(p.UkBorn)                               AS UkBorn,
				eg.Name                                                     AS EthnicGroup,
				-- RP-859 populate birth country consistently
				case 
					when p.UkBorn = 1 
					then 'UNITED KINGDOM' 
					else c.Name
				end 														AS BirthCountry,
				p.UkEntryYear                                               AS UkEntryYear,
				case 
					when po.Pcd2  is null 
					then '' 
					else po.Pcd2
				end                                                         AS Postcode,
				dbo.ufnYesNo(a.NoFixedAbode)                                AS NoFixedAbode,

				-- Geographies
				NULL                                                        AS LocalAuthority,
				NULL														AS LocalAuthorityCode,
				NULL														AS ResidencePhecCode,
				NULL                                                        AS ResidencePhec,
				NULL														AS TreatmentPhecCode,
				NULL                                                        AS TreatmentPhec,

				-- Clinical Details
				CONVERT(DATE, te.SymptomOnset)                              AS SymptomOnsetDate,
				CONVERT(DATE, te.DatePresented)                             AS PresentedDate,
				DATEDIFF(DAY,
					te.SymptomOnset, 
					te.DatePresented)                                       AS OnsetToPresentationDays,
				CONVERT(DATE, te.DateOfDiagnosis)                           AS DiagnosisDate, 
				DATEDIFF(DAY,
					te.DatePresented, 
					te.DateOfDiagnosis)                                     AS PresentationToDiagnosisDays,
				CONVERT(DATE, te.StartOfTreatment)                          AS StartOfTreatmentDate, 
				DATEDIFF(DAY,
					te.DateOfDiagnosis, 
					te.StartOfTreatment)                                    AS DiagnosisToTreatmentDays,
				DATEDIFF(DAY,
					te.SymptomOnset, 
					te.StartOfTreatment)                                    AS OnsetToTreatmentDays,
				dbo.ufnGetHivTestOffered_ETS (
					n.Id, 
					te.HIVTestOffered
				)															AS HivTestOffered,
				dbo.ufnGetETSSiteOfDisease(n.TuberculosisEpisodeId)            AS SiteOfDisease,
				ct.AdultContactsIdentified									AS AdultContactsIdentified,
				ct.ChildContactsIdentified									AS ChildContactsIdentified,
				ct.TotalContactsIdentified									AS TotalContactsIdentified,	
				ct.AdultContactsAssessed									AS AdultContactsAssessed,	
				ct.ChildContactsAssessed									AS ChildContactsAssessed,	
				ct.TotalContactsAssessed									AS TotalContactsAssessed,	
				ct.AdultContactsActiveTB									AS AdultContactsActiveTB,	
				ct.ChildContactsActiveTB									AS ChildContactsActiveTB,	
				ct.TotalContactsActiveTB									AS TotalContactsActiveTB,	
				ct.AdultContactsLTBI										AS AdultContactsLTBI,	
				ct.ChildContactsLTBI										AS ChildContactsLTBI,
				ct.TotalContactsLTBI										AS TotalContactsLTBI,	
				ct.AdultContactsLTBITreat									AS AdultContactsLTBITreat,	
				ct.ChildContactsLTBITreat									AS ChildContactsLTBITreat,	
				ct.TotalContactsLTBITreat									AS TotalContactsLTBITreat,	
				ct.AdultContactsLTBITreatComplete							AS AdultContactsLTBITreatComplete,	
				ct.ChildContactsLTBITreatComplete							AS ChildContactsLTBITreatComplete,	
				ct.TotalContactsLTBITreatComplete							AS TotalContactsLTBITreatComplete,
				dbo.ufnYesNoUnknown(th.PreviouslyDiagnosed)                 AS PreviouslyDiagnosed, 
				dbo.ufnEmptyOrIntValue(th.YearsSinceDiagnosis)              AS YearsSinceDiagnosis,
				(CASE th.PreviouslyDiagnosed
					WHEN 1 THEN dbo.ufnYesNo(th.DrugTherapyTreated)
					ELSE NULL
				END)                                                        AS PreviouslyTreated, 
				(CASE th.DrugTherapyTreated
					WHEN 1 THEN dbo.ufnYesNo(th.TreatmentInUK)
					ELSE NULL
				END)                                                        AS TreatmentInUk, 
				th.PreviousId                                               AS PreviousId, 
				dbo.ufnYesNoUnknown(th.BcgVaccinated)                       AS BcgVaccinated,

				-- Risk Factors
				dbo.ufnGetAnySocialRiskFactor (
					th.MisUse,
					th.ProblemUse,
					th.Homeless,
					th.PrisonAtDiagnosis
				)                                                           AS AnySocialRiskFactor,
				dbo.ufnYesNoUnknown(th.MisUse)                              AS AlcoholMisuse, 
				dbo.ufnYesNoUnknown(th.ProblemUse)                          AS DrugMisuse,
				dbo.ufnGetDrugUseStatus(
					1,
					th.ProblemUse, 
					n.TuberculosisHistoryId
				)														    AS CurrentDrugMisuse,
				dbo.ufnGetDrugUseStatus(
					2,
					th.ProblemUse, 
					n.TuberculosisHistoryId
				)                                                           AS DrugMisuseInLast5Years,
				dbo.ufnGetDrugUseStatus(
					3,
					th.ProblemUse, 
					n.TuberculosisHistoryId
				)                                                           AS DrugMisuseMoreThan5YearsAgo,
				dbo.ufnYesNoUnknown(th.Homeless)			                AS Homeless,
				dbo.ufnGetHomelessStatus(
					1,
					th.Homeless, 
					n.TuberculosisHistoryId
				)                                                           AS CurrentlyHomeless,
				dbo.ufnGetHomelessStatus(
					2,
					th.Homeless, 
					n.TuberculosisHistoryId
				)                                                           AS HomelessInLast5Years,
				dbo.ufnGetHomelessStatus(
					3,
					th.Homeless, 
					n.TuberculosisHistoryId
				)                                                           AS HomelessMoreThan5YearsAgo,
				dbo.ufnYesNoUnknown(th.PrisonAtDiagnosis)	                AS Prison,
				dbo.ufnGetPrisonStatus(
					1,
					th.PrisonAtDiagnosis, 
					n.TuberculosisHistoryId
				)                                                           AS CurrentlyInPrisonOrInPrisonWhenFirstSeen,
				dbo.ufnGetPrisonStatus(
					2,
					th.PrisonAtDiagnosis, 
					n.TuberculosisHistoryId
				)                                                           AS InPrisonInLast5Years,
				dbo.ufnGetPrisonStatus(
					3,
					th.PrisonAtDiagnosis, 
					n.TuberculosisHistoryId
				)                                                           AS InPrisonMoreThan5YearsAgo,
				dbo.ufnYesNoUnknown(th.Haspatienttravelledpriordiagonosis)  AS TravelledOutsideUk, 
				th.Countriestravelled                                       AS ToHowManyCountries, 
				dbo.ufnGetETSCountryName(th.TravelledCountryId1)               AS TravelCountry1, 
				dbo.ufnEmptyOrIntValue(th.Travelduration1)                  AS MonthsTravelled1,
				dbo.ufnGetETSCountryName(th.TravelledCountryId2)               AS TravelCountry2, 
				dbo.ufnEmptyOrIntValue(th.Travelduration2)                  AS MonthsTravelled2,
				dbo.ufnGetETSCountryName(th.TravelledCountryId3)               AS TravelCountry3, 
				dbo.ufnEmptyOrIntValue(th.Travelduration3)                  AS MonthsTravelled3,
				dbo.ufnYesNoUnknown(th.Haspatientreceivevisitors)           AS ReceivedVisitors, 
				th.Visitorcountrycount                                      AS FromHowManyCountries, 
				dbo.ufnGetETSCountryName(th.VisitorCountryId1)                 AS VisitorCountry1, 
				th.Visitduration1                                           AS DaysVisitorsStayed1,
				dbo.ufnGetETSCountryName(th.VisitorCountryId2)                 AS VisitorCountry2, 
				th.Visitduration1                                           AS DaysVisitorsStayed2,
				dbo.ufnGetETSCountryName(th.VisitorCountryId3)                 AS VisitorCountry3, 
				th.Visitduration3                                           AS DaysVisitorsStayed3,
				dbo.ufnYesNoUnknown(co.Diabetes)                            AS Diabetes, 
				dbo.ufnYesNoUnknown(co.HepatitisB)                          AS HepatitisB, 
				dbo.ufnYesNoUnknown(co.HepatitisC)                          AS HepatitisC, 
				dbo.ufnYesNoUnknown(co.ChronicLiverdisease)                 AS ChronicLiverDisease,		
				dbo.ufnYesNoUnknown(co.ChronicRenaldisease)                 AS ChronicRenalDisease, 
				dbo.ufnYesNoUnknown(co.Immunosuppression)                   AS ImmunoSuppression, 
				NULL                                                        AS BiologicalTherapy, 
				NULL                                                        AS Transplantation, 
				NULL                                                        AS OtherImmunoSuppression,
				dbo.ufnYesNoUnknown(co.Smoker)                              AS CurrentSmoker, 

				-- Treatment
				dbo.ufnYesNo(te.PostMortemDiagnosis)                        AS PostMortemDiagnosis, 
				dbo.ufnYesNo(te.DidNotStartTreatment)                       AS DidNotStartTreatment, 
				dbo.ufnYesNoNotknown(tp.ShortCourseTreatment)               AS ShortCourse, 
				dbo.ufnYesNoUnknown(tp.MDRTreatment)                        AS MdrTreatment, 
				CONVERT(DATE, tp.MDRTreatmentDate)                          AS MdrTreatmentDate,
				(CASE
					WHEN te.PostMortemDiagnosis = 1 THEN 'Died' -- Step no 1
					ELSE dbo.ufnGetTreatmentOutcome(
							'12',
							tr12.AnswerToCompleteQuestion,
							tr12.AnswerToIncompleteReason1,
							tr12.AnswerToIncompleteReason2
						 )
				END)                                                        AS TreatmentOutcome12months,
				(CASE
					WHEN tr24.Id IS NULL THEN '' -- Step no 1
					ELSE dbo.ufnGetTreatmentOutcome(
							'24',
							tr24.AnswerToCompleteQuestion,
							tr24.AnswerToIncompleteReason1,
							tr24.AnswerToIncompleteReason2
						 )
				END)                                                        AS TreatmentOutcome24months,
				(CASE
					WHEN tr36.Id IS NULL THEN '' -- Step no 1
					ELSE dbo.ufnGetTreatmentOutcome(
							'36',
							tr36.AnswerToCompleteQuestion,
							tr36.AnswerToIncompleteReason1,
							tr36.AnswerToIncompleteReason2
						 )
				END)                                                        AS TreatmentOutcome36months,
				NULL                                                        AS LastRecordedTreatmentOutcome,
				dbo.ufnGetDateOfDeath_ETS(
					te.DateOfDeath,
					tr12.DeathDate,
					tr24.DeathDate,
					tr36.DeathDate
				)                                                           AS DateOfDeath,
				dbo.ufnGetTreatmentEndDate_ETS(
					tr12.EndOfTreatmentDate,
					tr24.EndOfTreatmentDate,
					tr36.EndOfTreatmentDate
				)                                                           AS TreatmentEndDate,
				
				-- Culture & Resistance
				dbo.ufnYesNo(n.NoSampleTaken)                               AS NoSampleTaken, 
				NULL                                                        AS CulturePositive,
				dbo.ufnGetSpecies(n.LegacyId)                               AS Species,
				dbo.ufnGetEarliestSpecimenDate(n.LegacyId)                  AS EarliestSpecimenDate,
				NULL                                                        AS DrugResistanceProfile,
				NULL                                                        AS INH,
				NULL                                                        AS RIF,
				NULL                                                        AS EMB,
				NULL                                                        AS PZA,
				NULL                                                        AS AMINO,
				NULL                                                        AS QUIN,
				NULL                                                        AS MDR,
				NULL                                                        AS XDR,
				GETDATE()                                                   AS DataAsAt
			FROM [$(ETS)].dbo.Patient p
				INNER JOIN [$(ETS)].dbo.Notification n ON n.PatientId = p.Id
				LEFT OUTER JOIN [$(ETS)].dbo.Hospital h ON h.Id = n.HospitalId
				LEFT OUTER JOIN [$(ETS)].dbo.SystemUser s ON s.Id = n.OwnerUserId
				LEFT OUTER JOIN [$(ETS)].dbo.Address a ON a.Id = n.AddressId
				LEFT OUTER JOIN dbo.PostcodeLookup po ON po.PostcodeLookupId = a.PostcodeId
				LEFT OUTER JOIN [$(ETS)].dbo.TuberculosisEpisode te ON te.Id = n.TuberculosisEpisodeId
				LEFT OUTER JOIN [$(ETS)].dbo.TuberculosisHistory th ON th.Id = n.TuberculosisHistoryId
				LEFT OUTER JOIN [$(ETS)].dbo.TreatmentOutcome tr12 ON tr12.Id = n.TreatmentOutcomeId
				LEFT OUTER JOIN [$(ETS)].dbo.TreatmentOutcomeTwentyFourMonth tr24 ON tr24.Id = n.TreatmentOutcomeTwentyFourMonthId
				LEFT OUTER JOIN [$(ETS)].dbo.TreatmentOutcome36Month tr36 ON tr36.Id = n.TreatmentOutcome36MonthId
				LEFT OUTER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
				LEFT OUTER JOIN [$(ETS)].dbo.Comorbidities co ON co.Id = n.ComorbiditiesId
				LEFT OUTER JOIN [$(ETS)].dbo.ContactTracing ct ON ct.Id = n.ContactTracingId
				LEFT OUTER JOIN [$(ETS)].dbo.EthnicGroup eg ON eg.Id = p.EthnicGroupId
				LEFT OUTER JOIN [$(ETS)].dbo.Country C ON c.Id = p.BirthCountryId
				LEFT OUTER JOIN dbo.NotificationClusterMatch cluster ON cluster.NotificationId = n.LegacyId
			WHERE n.Submitted = 1
				AND n.AuditDelete IS NULL
				AND n.DenotificationId IS NULL
				AND (cluster.ClusterId IS NOT NULL OR YEAR(n.NotificationDate) IN (SELECT NotificationYear FROM vwNotificationYear))

			-- Populate NULL columns from above
			EXEC dbo.uspGenerateReusableResidence
			EXEC dbo.uspGenerateReusableTreatment
			EXEC dbo.uspGenerateReusableNotificationImmunosuppression
			EXEC dbo.uspGenerateReusableNotificationLastRecordedTreatmentOutcome_ETS
			EXEC dbo.uspGenerateReusableNotificationCulturePositive

			
			-- WARNING: The following 2nd argument will be used as an IN WHERE clause inside a dynamic SQL string that we pass together with single-quotes and commas
			EXEC dbo.uspGenerateReusableNotificationCultureResistance 'INH', '''ISO'', ''ISO_W'''
			EXEC dbo.uspGenerateReusableNotificationCultureResistance 'RIF', '''RIF'', ''RIF_W'''
			EXEC dbo.uspGenerateReusableNotificationCultureResistance 'EMB', '''ETHAM'', ''ETHAM_W'', ''ETA_W'''
			EXEC dbo.uspGenerateReusableNotificationCultureResistance 'PZA', '''PYR'', ''PYR_W'''
			EXEC dbo.uspGenerateReusableNotificationCultureResistance 'AMINO', '''AK'', ''AMI'', ''KAN'', ''CAP'', ''AMINO_W'''
			EXEC dbo.uspGenerateReusableNotificationCultureResistance 'QUIN', '''OFX'', ''MOXI'', ''CIP'', ''QUIN_W'''

			-- Populate more NULL columns from above
			EXEC dbo.uspGenerateReusableNotificationMdr
			EXEC dbo.uspGenerateReusableNotificationXdr
			EXEC dbo.uspGenerateReusableNotificationDrugResistanceProfile
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
