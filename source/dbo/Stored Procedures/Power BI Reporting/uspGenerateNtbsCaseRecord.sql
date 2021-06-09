CREATE PROCEDURE [dbo].[uspGenerateNtbsCaseRecord]
AS
BEGIN TRY
	DECLARE @TempDiseaseSites TABLE
	(
		NotificationId int,
		[Description] nvarchar(2000)
	);

	INSERT INTO @TempDiseaseSites
	SELECT rr.NotificationId, [Description] = STRING_AGG([Description], N', ')
		FROM RecordRegister rr
			INNER JOIN [$(NTBS)].[dbo].[NotificationSite] notificationSite ON rr.NotificationId = notificationSite.NotificationId
			INNER JOIN [$(NTBS)].[ReferenceData].[Site] sites ON notificationSite.SiteId = sites.SiteId
		WHERE rr.SourceSystem = 'NTBS'
		GROUP BY rr.NotificationId;

	INSERT INTO [dbo].[Record_CaseData](
		[NotificationId]
		,[EtsId]
		,[LtbrId]
		,[LinkedNotifications]
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
		,[EnhancedCaseManagement]
		,[EnhancedCaseManagementLevel]
		,[DOTOffered]
		,[DOTReceived]
		,[TestPerformed]
		,[ChestXRayResult]
		,[TreatmentOutcome12months]
		,[TreatmentOutcome24months]
		,[TreatmentOutcome36months]
		,[LastRecordedTreatmentOutcome]
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
		,[SmokerInLast5Years]
		,[SmokerMoreThan5YearsAgo]
		,[MentalHealth]
		,[AsylumSeeker]
		,[ImmigrationDetainee]
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
		rr.NotificationId										AS NotificationId
		,n.ETSID												AS EtsId
		,n.LTBRID												AS LtbrId
		,NULL													AS LinkedNotifications --TODO
		,u.DisplayName											AS CaseManager
		,hd.Consultant											AS Consultant
		,hd.HospitalId											AS HospitalID
		,dbo.ufnGetAgefrom(p.Dob,n.NotificationDate)			AS Age
		,s.[Label]												AS Sex
		,dbo.ufnUkBorn(p.CountryId)								AS UKBorn
		,e.[Label]												AS EthnicGroup
		,(CASE
			WHEN occ.HasFreeTextField = 1 THEN p.OccupationOther
			ELSE occ.[Role]
			END)												AS Occupation
		,occ.[Sector]											AS OccupationCategory
		,dbo.ufnGetCountryName(p.CountryId)						AS BirthCountry
		,p.YearOfUkEntry										AS UkEntryYear
		,dbo.ufnYesNo(p.NoFixedAbode)							AS NoFixedAbode

		--clinical dates are next. We will want to extend these to include the additional dates captured in NTBS
		,dbo.ufnYesNo(cd.IsSymptomatic)							AS Symptomatic
		,cd.SymptomStartDate									AS SymptomOnsetDate
		,cd.FirstPresentationDate								AS FirstPresentationDate
		,CAST((DATEDIFF(DAY,
						cd.SymptomStartDate,
						cd.FirstPresentationDate))
					AS SMALLINT)								AS OnsetToFirstPresentationDays
		,cd.TBServicePresentationDate							AS TbServicePresentationDate
		,CAST((DATEDIFF(DAY,
						cd.FirstPresentationDate,
						cd.TBServicePresentationDate))
					AS SMALLINT)								AS FirstPresentationToTbServicePresentationDays
		,cd.DiagnosisDate										AS DiagnosisDate
		,CAST((DATEDIFF(DAY,
						cd.TBServicePresentationDate,
						cd.DiagnosisDate))
					AS SMALLINT)								AS PresentationToDiagnosisDays
		,cd.TreatmentStartDate									AS StartOfTreatmentDate
		,CAST((DATEDIFF(DAY,
						cd.DiagnosisDate,
						cd.TreatmentStartDate))
					AS SMALLINT)								AS DiagnosisToTreatmentDays
		,CAST((DATEDIFF(DAY,
						cd.SymptomStartDate,
						cd.TreatmentStartDate))
					AS SMALLINT)								AS OnsetToTreatmentDays
		,dbo.ufnGetHIVValue (cd.HIVTestState)					AS HivTestOffered
		--summarise sites of disease
		,dbo.ufnGetSiteOfDisease(rr.NotificationId)				AS SiteOfDisease
		,diseaseSites.[Description]								AS DiseaseSiteList
		,dbo.ufnYesNo(cd.IsPostMortem)							AS PostMortemDiagnosis
		--invert value as stored the wrong way round in the database
		,dbo.ufnYesNo(~cd.DidNotStartTreatment)					AS StartedTreatment
		,trl.TreatmentRegimenDescription						AS TreatmentRegimen
		,cd.MDRTreatmentStartDate								AS MdrTreatmentDate
		,cd.EnhancedCaseManagementStatus						AS EnhancedCaseManagement
		,cd.EnhancedCaseManagementLevel							AS EnhancedCaseManagementLevel
		,cd.IsDotOffered										AS DOTOffered
		,dl.DOTReceived											AS DOTReceived
		,dbo.ufnYesNo(ted.HasTestCarriedOut)					AS TestPerformed
		,ChestXRayResult										AS ChestXRayResult
		--Outcomes are done in a separate function later on
		,NULL													AS TreatmentOutcome12months
		,NULL													AS TreatmentOutcome24months
		,NULL													AS TreatmentOutcome36months
		,NULL													AS LastRecordedTreatmentOutcome
		--date of death fetched from the Treatment Event table
		,dbo.ufnGetDateOfDeath(n.NotificationId)				AS DateOfDeath
		,dbo.ufnGetTreatmentEndDate(n.NotificationId)			AS TreatmentEndDate
		--Contact Tracing
		,ct.AdultsIdentified									AS AdultContactsIdentified
		,ct.ChildrenIdentified									AS ChildContactsIdentified
		,[dbo].[ufnCalcContactTracingTotals](ct.AdultsIdentified, ct.ChildrenIdentified)
																AS TotalContactsIdentified
		,ct.AdultsScreened										AS AdultContactsAssessed
		,ct.ChildrenScreened									AS ChildContactsAssessed
		,[dbo].[ufnCalcContactTracingTotals]
			(ct.AdultsScreened, ct.ChildrenScreened)			AS TotalContactsAssessed
		,ct.AdultsActiveTB										AS AdultContactsActiveTB
		,ct.ChildrenActiveTB									AS ChildContactsActiveTB
		,[dbo].[ufnCalcContactTracingTotals]
			(ct.AdultsActiveTB, ct.ChildrenActiveTB)			AS TotalContactsActiveTB
		,ct.AdultsLatentTB										AS AdultContactsLTBI
		,ct.ChildrenLatentTB									AS ChildContactsLTBI
		,[dbo].[ufnCalcContactTracingTotals]
			(ct.AdultsLatentTB, ct.ChildrenLatentTB)			AS TotalContactsLTBI
		,ct.AdultsStartedTreatment								AS AdultContactsLTBITreat
		,ct.ChildrenStartedTreatment							AS ChildContactsLTBITreat
		,[dbo].[ufnCalcContactTracingTotals](ct.AdultsStartedTreatment, ct.ChildrenStartedTreatment)
																AS TotalContactsLTBITreat
		,ct.AdultsFinishedTreatment								AS AdultContactsLTBITreatComplete
		,ct.ChildrenFinishedTreatment							AS ChildContactsLTBITreatComplete
		,[dbo].[ufnCalcContactTracingTotals](ct.AdultsFinishedTreatment,ct.ChildrenFinishedTreatment)
																AS TotalContactsLTBITreatComplete
		--non-NTBS Diagnosis
		,pth.PreviouslyHadTb            						AS PreviouslyDiagnosed
		,DATEPART(YEAR, n.NotificationDate)-
			pth.PreviousTbDiagnosisYear							AS YearsSinceDiagnosis
		,pth.PreviouslyTreated									AS PreviouslyTreated
		,(CASE
			WHEN ptc.IsoCode = 'GB' THEN 'Yes'
			WHEN ptc.IsoCode IS NOT NULL THEN 'No'
			ELSE NULL
		END)		            								AS TreatmentInUK
		,cd.BCGVaccinationState									AS BcgVaccinated
		--social risk factors
		,NULL													AS AnySocialRiskFactor -- updated at end
		,srf.AlcoholMisuseStatus								AS AlcoholMisuse
		,rfd.[Status]											AS DrugMisuse
		,dbo.ufnYesNo(rfd.IsCurrent)							AS CurrentDrugMisuse
		,dbo.ufnYesNo(rfd.InPastFiveYears)						AS DrugMisuseInLast5Years
		,dbo.ufnYesNo(rfd.MoreThanFiveYearsAgo)					AS DrugMisuseMoreThan5YearsAgo
		,rfh.[Status]											AS Homeless
		,dbo.ufnYesNo(rfh.IsCurrent)							AS CurrentlyHomeless
		,dbo.ufnYesNo(rfh.InPastFiveYears)						AS HomelessInLast5Years
		,dbo.ufnYesNo(rfh.MoreThanFiveYearsAgo)					AS HomelessMoreThan5YearsAgo
		,rfp.[Status]											AS Prison
		,dbo.ufnYesNo(rfp.IsCurrent)							AS CurrentlyInPrisonOrInPrisonWhenFirstSeen
		,dbo.ufnYesNo(rfp.InPastFiveYears)						AS InPrisonInLast5Years
		,dbo.ufnYesNo(rfp.MoreThanFiveYearsAgo)					AS InPrisonMoreThan5YearsAgo
		,rfs.[Status]											AS Smoking
		,dbo.ufnYesNo(rfs.IsCurrent)							AS CurrentSmoker
		,dbo.ufnYesNo(rfs.InPastFiveYears)						AS SmokerInLast5Years
		,dbo.ufnYesNo(rfs.MoreThanFiveYearsAgo)					AS SmokerMoreThan5YearsAgo
		,srf.MentalHealthStatus									AS MentalHealth
		,srf.AsylumSeekerStatus									AS AsylumSeeker
		,srf.ImmigrationDetaineeStatus							AS ImmigrationDetainee

		--travel and visitors
		,td.HasTravel											AS TravelledOutsideUk
		,td.TotalNumberOfCountries								AS ToHowManyCountries
		,dbo.ufnGetCountryName(td.Country1Id)					AS TravelCountry1
		,td.StayLengthInMonths1									AS MonthsTravelled1
		,dbo.ufnGetCountryName(td.Country2Id)					AS TravelCountry2
		,td.StayLengthInMonths2									AS MonthsTravelled2
		,dbo.ufnGetCountryName(td.Country3Id)					AS TravelCountry3
		,td.StayLengthInMonths3									AS MonthsTravelled3
		,vd.HasVisitor											AS ReceivedVisitors
		,vd.TotalNumberOfCountries								AS FromHowManyCountries
		,dbo.ufnGetCountryName(vd.Country1Id)					AS VisitorCountry1
		,vd.StayLengthInMonths1									AS MonthsVisitorsStayed1
		,dbo.ufnGetCountryName(vd.Country2Id)					AS VisitorCountry2
		,vd.StayLengthInMonths2									AS MonthsVisitorsStayed2
		,dbo.ufnGetCountryName(vd.Country3Id)					AS VisitorCountry3
		,vd.StayLengthInMonths3									AS DaysVisitorsStayed3
		--comorbidities
		,cod.DiabetesStatus										AS Diabetes
		,cod.HepatitisBStatus									AS HepatitisB
		,cod.HepatitisCStatus									AS HepatitisC
		,cod.LiverDiseaseStatus									AS ChronicLiverDisease
		,cod.RenalDiseaseStatus									AS ChronicRenalDisease
		,id.[Status]											AS ImmunoSuppression
		,dbo.ufnYesNo(id.HasBioTherapy)							AS BiologicalTherapy
		,dbo.ufnYesNo(id.HasTransplantation)					AS Transplantation
		,dbo.ufnYesNo(id.HasOther)								AS OtherImmunoSuppression
		,GETUTCDATE()											AS DataRefreshedAt
	FROM [dbo].[RecordRegister] rr
		INNER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = rr.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[User] u ON u.Id = hd.CaseManagerId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Patients] p on p.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].Occupation occ ON occ.OccupationId = p.OccupationId
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[Sex] s ON s.SexId = p.SexId
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[Ethnicity] e ON e.EthnicityId = p.EthnicityId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ClinicalDetails] cd ON cd.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ContactTracing] ct ON ct.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[PreviousTbHistory] pth ON pth.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[Country] ptc ON pth.PreviousTreatmentCountryId = ptc.CountryId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[SocialRiskFactors] srf ON srf.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[RiskFactorDrugs] rfd ON rfd.SocialRiskFactorsNotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[RiskFactorHomelessness] rfh ON rfh.SocialRiskFactorsNotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[RiskFactorImprisonment] rfp ON rfp.SocialRiskFactorsNotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[RiskFactorSmoking] rfs ON rfs.SocialRiskFactorsNotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[TravelDetails] td ON td.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[VisitorDetails] vd ON vd.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ComorbidityDetails] cod ON cod.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ImmunosuppressionDetails] id ON id.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[TestData] ted ON ted.NotificationId = n.NotificationId
		LEFT OUTER JOIN [dbo].[TreatmentRegimenLookup] trl ON trl.TreatmentRegimenCode = cd.TreatmentRegimen
		LEFT OUTER JOIN [dbo].[DOTLookup] dl ON dl.SystemValue = cd.DotStatus
		LEFT OUTER JOIN @TempDiseaseSites diseaseSites ON diseaseSites.NotificationId = n.NotificationId
		OUTER APPLY [dbo].[ufnGetCaseRecordChestXrayResults](rr.NotificationId, cd.DiagnosisDate) ChestXRayResult
	WHERE rr.SourceSystem = 'NTBS'

	--'Sample taken' should be set if there are any manually-entered test results which are NOT of type chest x-ray
	UPDATE cd
		SET SampleTaken = CASE WHEN manualresults.NotificationId IS NULL THEN 'No' ELSE 'Yes' END

	FROM [dbo].[Record_CaseData] cd
		LEFT OUTER JOIN (
			SELECT mr.NotificationId
			FROM [$(NTBS)].[dbo].[ManualTestResult] mr
				INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = mr.NotificationId
			WHERE ManualTestTypeId != 4
			) AS manualresults ON manualresults.NotificationId = cd.NotificationId

	EXEC [dbo].uspGenerateRecordOutcome


END TRY
BEGIN CATCH
	THROW
END CATCH
