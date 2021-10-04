CREATE PROCEDURE [dbo].[uspGenerateEtsCaseRecord]
AS
BEGIN TRY
	DECLARE @TempDiseaseSites TABLE
	(
		TuberculosisEpisodeId uniqueidentifier,
		[Description] nvarchar(2000)
	);

	INSERT INTO @TempDiseaseSites
	SELECT n.TuberculosisEpisodeId, STRING_AGG(sites.[Name], N', ') WITHIN GROUP (ORDER BY ord.OrderIndex) AS [Description]
		FROM RecordRegister rr
			INNER JOIN [$(ETS)].dbo.[Notification] n ON rr.NotificationId = n.LegacyId
			INNER JOIN [$(ETS)].dbo.TuberculosisEpisodeDiseaseSite diseaseSite ON n.TuberculosisEpisodeId = diseaseSite.TuberculosisEpisodeId
			INNER JOIN [$(ETS)].dbo.DiseaseSite sites ON sites.Id = diseaseSite.DiseaseSiteId
			LEFT JOIN DiseaseSiteOrdering ord ON ord.EtsID = sites.Id
		WHERE rr.SourceSystem = 'ETS' AND diseaseSite.AuditDelete IS NULL
		GROUP BY n.TuberculosisEpisodeId;

	INSERT INTO [dbo].[Record_CaseData](
		[NotificationId]
		,[EtsId]
		,[LtbrId]
		,[CaseManager]
		,[Consultant]
		,[HospitalId]
		,[Age]
		,[Sex]
		,[UkBorn]
		,[EthnicGroup]
		,[Occupation]
		,[OccupationCategory]
		,[BirthCountry]
		,[UkEntryYear]
		,[NoFixedAbode]
		,[Symptomatic]
		,[SymptomOnsetDate]
		,[FirstPresentationDate]
		,[OnsetToFirstPresentationDays]
		,[TbServicePresentationDate]
		,[FirstPresentationToTbServicePresentationDays]
		,[DiagnosisDate]
		,[PresentationToDiagnosisDays]
		,[StartOfTreatmentDate]
		,[DiagnosisToTreatmentDays]
		,[OnsetToTreatmentDays]
		,[HivTestOffered]
		,[SiteOfDisease]
		,[DiseaseSiteList]
		,[PostMortemDiagnosis]
		,[StartedTreatment]
		,[TreatmentRegimen]
		,[MdrTreatmentDate]
		,[DOTOffered]
		,[DOTReceived]
		,[TestPerformed]
		,[SampleTaken]
		,[TreatmentOutcome12months]
		,[TreatmentOutcome24months]
		,[TreatmentOutcome36months]
		,[DateOfDeath]
		,[TreatmentEndDate]
		,[AdultContactsIdentified]
		,[ChildContactsIdentified]
		,[TotalContactsIdentified]
		,[AdultContactsAssessed]
		,[ChildContactsAssessed]
		,[TotalContactsAssessed]
		,[AdultContactsActiveTB]
		,[ChildContactsActiveTB]
		,[TotalContactsActiveTB]
		,[AdultContactsLTBI]
		,[ChildContactsLTBI]
		,[TotalContactsLTBI]
		,[AdultContactsLTBITreat]
		,[ChildContactsLTBITreat]
		,[TotalContactsLTBITreat]
		,[AdultContactsLTBITreatComplete]
		,[ChildContactsLTBITreatComplete]
		,[TotalContactsLTBITreatComplete]
		,[PreviouslyDiagnosed]
		,[YearsSinceDiagnosis]
		,[PreviouslyTreated]
		,[TreatmentInUk]
		,[PreviousId]
		,[BcgVaccinated]
		,[AnySocialRiskFactor]
		,[AlcoholMisuse]
		,[DrugMisuse]
		,[CurrentDrugMisuse]
		,[DrugMisuseInLast5Years]
		,[DrugMisuseMoreThan5YearsAgo]
		,[Homeless]
		,[CurrentlyHomeless]
		,[HomelessInLast5Years]
		,[HomelessMoreThan5YearsAgo]
		,[Prison]
		,[CurrentlyInPrisonOrInPrisonWhenFirstSeen]
		,[InPrisonInLast5Years]
		,[InPrisonMoreThan5YearsAgo]
		,[Smoking]
		,[CurrentSmoker]
		,[TravelledOutsideUk]
		,[ToHowManyCountries]
		,[TravelCountry1]
		,[MonthsTravelled1]
		,[TravelCountry2]
		,[MonthsTravelled2]
		,[TravelCountry3]
		,[MonthsTravelled3]
		,[ReceivedVisitors]
		,[FromHowManyCountries]
		,[VisitorCountry1]
		,[MonthsVisitorsStayed1]
		,[VisitorCountry2]
		,[MonthsVisitorsStayed2]
		,[VisitorCountry3]
		,[MonthsVisitorsStayed3]
		,[Diabetes]
		,[HepatitisB]
		,[HepatitisC]
		,[ChronicLiverDisease]
		,[ChronicRenalDisease]
		,[ImmunoSuppression]
		,[BiologicalTherapy]
		,[Transplantation]
		,[OtherImmunoSuppression]
		,[DataRefreshedAt])
	SELECT

		-- Primary key
		rr.NotificationId												AS NotificationId
		,n.LegacyId														AS EtsId
		,dbo.ufnNormalizeLtbrId(n.AuditMigrateId)						AS LtbrId
		,s.Forename + ' ' + s.Surname									AS CaseManager
		,n.PatientConsultant											AS Consultant
		,CONVERT(VARCHAR(36), n.HospitalId)								AS HospitalId
		,dbo.ufnGetAgefrom(p.DateOfBirth,n.NotificationDate)			AS Age
		,dbo.ufnSex(p.Sex)												AS Sex
		,dbo.ufnYesNoUnknown(p.UkBorn)									AS UkBorn
		,eg.[Name]														AS EthnicGroup
		,CASE
			WHEN n.OccupationId IS NULL THEN n.OccupationOther
			ELSE occ.[Name]
		END																AS Occupation
		,occat.[Name]													AS OccupationCategory
		-- RP-859 populate birth country consistently
		,dbo.ufnGetEtsBirthCountryAsNtbsCountry(p.UkBorn, p.BirthCountryId) AS BirthCountry
		,p.UkEntryYear													AS UkEntryYear
		,dbo.ufnYesNo(a.NoFixedAbode)									AS NoFixedAbode

		--symptomatic is not a field in NTBS but we can derive that it should be 'Yes' if there is a SymptomOnSetDate
		--otherwise leave it empty
		,CASE
			WHEN te.SymptomOnset IS NOT NULL THEN 'Yes'
		END																AS Symptomatic

		-- Clinical Details
		,CONVERT(DATE, te.SymptomOnset)									AS SymptomOnsetDate
		,CONVERT(DATE, te.DatePresented)								AS FirstPresentedDate
		,DATEDIFF(DAY,
			te.SymptomOnset,
			te.DatePresented)											AS OnsetToFirstPresentationDays
		--presentation to TB service doesn't exist in ETS so cannot be set
		,NULL															AS TbServicePresentationDate
		,NULL															AS FirstPresentationToTbServicePresentationDays
		,CONVERT(DATE, te.DateOfDiagnosis)								AS DiagnosisDate
		,DATEDIFF(DAY,
			te.DatePresented,
			te.DateOfDiagnosis)											AS PresentationToDiagnosisDays
		,CONVERT(DATE, te.StartOfTreatment)								AS StartOfTreatmentDate
		,DATEDIFF(DAY,
			te.DateOfDiagnosis,
			te.StartOfTreatment)										AS DiagnosisToTreatmentDays
		,DATEDIFF(DAY,
			te.SymptomOnset,
			te.StartOfTreatment)										AS OnsetToTreatmentDays
		,te.HIVTestOffered												AS HivTestOffered
		,dbo.ufnGetETSSiteOfDisease(n.TuberculosisEpisodeId)			AS SiteOfDisease
		,diseaseSites.[Description]										AS DiseaseSiteList

		-- Treatment
		,dbo.ufnYesNo(te.PostMortemDiagnosis)							AS PostMortemDiagnosis
		,CASE WHEN te.StartOfTreatment IS NOT NULL THEN 'Yes'
			ELSE dbo.ufnYesNo(~te.DidNotStartTreatment) END				AS StartedTreatment
		,NULL															AS TreatmentRegimen
		,CONVERT(DATE, tp.MDRTreatmentDate)								AS MdrTreatmentDate
		,dl.DOTOffered													AS DOTOffered
		,dl.DOTReceived													AS DOTReceived
		--we need to reverse ETS' no sample taken. So if no sample taken = yes, no test was performed
		--if it = no, it means a test was performed
		,CASE
			WHEN n.NoSampleTaken IS NULL THEN NULL
			WHEN n.NoSampleTaken = 1 THEN 'No'
			WHEN n.NoSampleTaken = 0 THEN 'Yes'
		END																AS TestPerformed
		--the same logic is used to set 'Sample Taken'
		,CASE
			WHEN n.NoSampleTaken IS NULL THEN NULL
			WHEN n.NoSampleTaken = 1 THEN 'No'
			WHEN n.NoSampleTaken = 0 THEN 'Yes'
		END																AS SampleTaken
		,(CASE
			WHEN te.PostMortemDiagnosis = 1 THEN 'Died' -- Step no 1
			ELSE dbo.ufnGetTreatmentOutcome(
					'12',
					tr12.AnswerToCompleteQuestion,
					tr12.AnswerToIncompleteReason1,
					tr12.AnswerToIncompleteReason2
					)
		END)															AS TreatmentOutcome12months
		,(CASE
			WHEN tr24.Id IS NULL THEN NULL -- Step no 1
			ELSE dbo.ufnGetTreatmentOutcome(
					'24',
					tr24.AnswerToCompleteQuestion,
					tr24.AnswerToIncompleteReason1,
					tr24.AnswerToIncompleteReason2
					)
		END)															AS TreatmentOutcome24months
		,(CASE
			WHEN tr36.Id IS NULL THEN NULL -- Step no 1
			ELSE dbo.ufnGetTreatmentOutcome(
					'36',
					tr36.AnswerToCompleteQuestion,
					tr36.AnswerToIncompleteReason1,
					tr36.AnswerToIncompleteReason2
					)
		END)															AS TreatmentOutcome36months
		,dbo.ufnGetDateOfDeath_ETS(
			te.DateOfDeath,
			tr12.DeathDate,
			tr24.DeathDate,
			tr36.DeathDate
			)                                                           AS DateOfDeath
		,dbo.ufnGetTreatmentEndDate_ETS(
			tr12.EndOfTreatmentDate,
			tr24.EndOfTreatmentDate,
			tr36.EndOfTreatmentDate
		)																AS TreatmentEndDate

		--contact tracing
		,ct.AdultContactsIdentified										AS AdultContactsIdentified
		,ct.ChildContactsIdentified										AS ChildContactsIdentified
		,ct.TotalContactsIdentified										AS TotalContactsIdentified
		,ct.AdultContactsAssessed										AS AdultContactsAssessed
		,ct.ChildContactsAssessed										AS ChildContactsAssessed
		,ct.TotalContactsAssessed										AS TotalContactsAssessed
		,ct.AdultContactsActiveTB										AS AdultContactsActiveTB
		,ct.ChildContactsActiveTB										AS ChildContactsActiveTB
		,ct.TotalContactsActiveTB										AS TotalContactsActiveTB
		,ct.AdultContactsLTBI											AS AdultContactsLTBI
		,ct.ChildContactsLTBI											AS ChildContactsLTBI
		,ct.TotalContactsLTBI											AS TotalContactsLTBI
		,ct.AdultContactsLTBITreat										AS AdultContactsLTBITreat
		,ct.ChildContactsLTBITreat										AS ChildContactsLTBITreat
		,ct.TotalContactsLTBITreat										AS TotalContactsLTBITreat
		,ct.AdultContactsLTBITreatComplete								AS AdultContactsLTBITreatComplete
		,ct.ChildContactsLTBITreatComplete								AS ChildContactsLTBITreatComplete
		,ct.TotalContactsLTBITreatComplete								AS TotalContactsLTBITreatComplete

		--risk factors
		,dbo.ufnYesNoUnknown(th.PreviouslyDiagnosed)					AS PreviouslyDiagnosed
		,dbo.ufnEmptyOrIntValue(th.YearsSinceDiagnosis)					AS YearsSinceDiagnosis
		,(CASE th.PreviouslyDiagnosed
			WHEN 1 THEN dbo.ufnYesNo(th.DrugTherapyTreated)
			ELSE NULL
		END)															AS PreviouslyTreated
		,(CASE th.DrugTherapyTreated
			WHEN 1 THEN dbo.ufnYesNo(th.TreatmentInUK)
			ELSE NULL
		END)															AS TreatmentInUk
		,th.PreviousId													AS PreviousId
		,dbo.ufnYesNoUnknown(th.BcgVaccinated)							AS BcgVaccinated
		,NULL															AS AnySocialRiskFactor --set later
		,dbo.ufnYesNoUnknown(th.MisUse)									AS AlcoholMisuse
		,dbo.ufnYesNoUnknown(th.ProblemUse)								AS DrugMisuse
		,dbo.ufnGetDrugUseStatus(
			1,
			th.ProblemUse,
			n.TuberculosisHistoryId
		)																AS CurrentDrugMisuse
		,dbo.ufnGetDrugUseStatus(
			2,
			th.ProblemUse,
			n.TuberculosisHistoryId
		)																AS DrugMisuseInLast5Years
		,dbo.ufnGetDrugUseStatus(
			3,
			th.ProblemUse,
			n.TuberculosisHistoryId
		)																AS DrugMisuseMoreThan5YearsAgo


		,dbo.ufnYesNoUnknown(th.Homeless)								AS Homeless
		,dbo.ufnGetHomelessStatus(
			1,
			th.Homeless,
			n.TuberculosisHistoryId
		)																AS CurrentlyHomeless
		,dbo.ufnGetHomelessStatus(
			2,
			th.Homeless,
			n.TuberculosisHistoryId
		)																AS HomelessInLast5Years
		,dbo.ufnGetHomelessStatus(
			3,
			th.Homeless,
			n.TuberculosisHistoryId
		)																AS HomelessMoreThan5YearsAgo
		,dbo.ufnYesNoUnknown(th.PrisonAtDiagnosis)						AS Prison
		,dbo.ufnGetPrisonStatus(
			1,
			th.PrisonAtDiagnosis,
			n.TuberculosisHistoryId
		)																AS CurrentlyInPrisonOrInPrisonWhenFirstSeen
		,dbo.ufnGetPrisonStatus(
			2,
			th.PrisonAtDiagnosis,
			n.TuberculosisHistoryId
		)																AS InPrisonInLast5Years
		,dbo.ufnGetPrisonStatus(
			3,
			th.PrisonAtDiagnosis,
			n.TuberculosisHistoryId
		)																AS InPrisonMoreThan5YearsAgo
		,dbo.ufnYesNoUnknown(co.Smoker)									AS Smoking
		,dbo.ufnYesNoUnknown(co.Smoker)									AS CurrentSmoker
		--travel
		,dbo.ufnYesNoUnknown(th.Haspatienttravelledpriordiagonosis)		AS TravelledOutsideUk
		,REPLACE(th.Countriestravelled, '+', '')						AS ToHowManyCountries
		,dbo.ufnGetETSCountryName(th.TravelledCountryId1)               AS TravelCountry1
		,dbo.ufnEmptyOrIntValue(th.Travelduration1)						AS MonthsTravelled1
		,dbo.ufnGetETSCountryName(th.TravelledCountryId2)               AS TravelCountry2
		,dbo.ufnEmptyOrIntValue(th.Travelduration2)						AS MonthsTravelled2
		,dbo.ufnGetETSCountryName(th.TravelledCountryId3)               AS TravelCountry3
		,dbo.ufnEmptyOrIntValue(th.Travelduration3)						AS MonthsTravelled3
		,dbo.ufnYesNoUnknown(th.Haspatientreceivevisitors)				AS ReceivedVisitors
		,th.Visitorcountrycount											AS FromHowManyCountries
		,dbo.ufnGetETSCountryName(th.VisitorCountryId1)                 AS VisitorCountry1
		,dbo.ufnMapEtsVisitorDurationToMonths(th.Visitduration1)		AS MonthsVisitorsStayed1
		,dbo.ufnGetETSCountryName(th.VisitorCountryId2)                 AS VisitorCountry2
		,dbo.ufnMapEtsVisitorDurationToMonths(th.Visitduration2)		AS MonthsVisitorsStayed2
		,dbo.ufnGetETSCountryName(th.VisitorCountryId3)                 AS VisitorCountry3
		,dbo.ufnMapEtsVisitorDurationToMonths(th.Visitduration3)		AS MonthsVisitorsStayed3
		,dbo.ufnYesNoUnknown(co.Diabetes)								AS Diabetes
		,dbo.ufnYesNoUnknown(co.HepatitisB)								AS HepatitisB
		,dbo.ufnYesNoUnknown(co.HepatitisC)								AS HepatitisC
		,dbo.ufnYesNoUnknown(co.ChronicLiverdisease)					AS ChronicLiverDisease
		,dbo.ufnYesNoUnknown(co.ChronicRenaldisease)					AS ChronicRenalDisease
		,dbo.ufnYesNoUnknown(co.Immunosuppression)						AS ImmunoSuppression
		,NULL															AS BiologicalTherapy
		,NULL															AS Transplantation
		,NULL															AS OtherImmunoSuppression
		,GETUTCDATE()													AS DataRefreshedAt
	FROM [dbo].[RecordRegister] rr
		INNER JOIN [$(ETS)].[dbo].[Notification] n ON n.LegacyId = rr.NotificationId
		INNER JOIN [$(ETS)].[dbo].[Patient] p ON p.Id = n.PatientId
		LEFT OUTER JOIN [$(ETS)].dbo.Address a ON a.Id = n.AddressId
		LEFT OUTER JOIN [$(ETS)].dbo.SystemUser s ON s.Id = n.OwnerUserId
		LEFT OUTER JOIN [$(ETS)].dbo.TuberculosisEpisode te ON te.Id = n.TuberculosisEpisodeId
		LEFT OUTER JOIN [$(ETS)].dbo.TuberculosisHistory th ON th.Id = n.TuberculosisHistoryId
		LEFT OUTER JOIN [$(ETS)].dbo.TreatmentOutcome tr12 ON tr12.Id = n.TreatmentOutcomeId
		LEFT OUTER JOIN [$(ETS)].dbo.TreatmentOutcomeTwentyFourMonth tr24 ON tr24.Id = n.TreatmentOutcomeTwentyFourMonthId
		LEFT OUTER JOIN [$(ETS)].dbo.TreatmentOutcome36Month tr36 ON tr36.Id = n.TreatmentOutcome36MonthId
		LEFT OUTER JOIN [$(ETS)].dbo.TreatmentPlanned tp ON tp.Id = n.TreatmentPlannedId
		LEFT OUTER JOIN [$(ETS)].dbo.Comorbidities co ON co.Id = n.ComorbiditiesId
		LEFT OUTER JOIN [$(ETS)].dbo.ContactTracing ct ON ct.Id = n.ContactTracingId
		LEFT OUTER JOIN [$(ETS)].dbo.EthnicGroup eg ON eg.Id = p.EthnicGroupId
		LEFT OUTER JOIN [$(ETS)].dbo.Occupation occ ON occ.Id = n.OccupationId
		LEFT OUTER JOIN [$(ETS)].dbo.OccupationCategory occat ON occat.Id = n.OccupationCategoryId
		LEFT OUTER JOIN [dbo].[DOTLookup] dl ON dl.SystemValue = CONVERT(VARCHAR, tp.DirectObserv)
		LEFT OUTER JOIN @TempDiseaseSites diseaseSites ON diseaseSites.TuberculosisEpisodeId = te.Id
	WHERE rr.SourceSystem = 'ETS'

	EXEC [dbo].[uspGenerateEtsImmunosuppression]

	EXEC [dbo].[uspGenerateEtsTreatmentRegimen]

END TRY
BEGIN CATCH
	THROW
END CATCH
