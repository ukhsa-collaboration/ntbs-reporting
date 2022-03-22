CREATE VIEW [dbo].[vwEtsLegacyExtract]
	AS 
	SELECT
		dem.Id
		,dem.Id AS EtsId
		,dem.IDOriginal AS LtbrId
		,dem.LocalPatientId
		,dem.CaseReportDate
		,YEAR(rr.NotificationDate) AS ReportYear
		,dem.Denotified
		,dem.DenotificationDate
		,dem.DenotificationComments
		,dem.CaseManager
		,dem.Hospital
		,dem.PatientsConsultant AS Consultant
		,dem.Title
		,dem.Forename
		,dem.Surname
		,dem.NHSNumber
		,dem.Sex
		,dem.Age
		,dem.DateOfBirth
		,dem.AddressLine1
		,dem.AddressLine2
		,dem.Town
		,dem.county AS County
		,dem.Postcode
		,dem.PCT
		,dem.HPU
		,dem.LocalAuthority
		,dem.Region
		,dem.Occupation
		,dem.OccupationCategory
		,dem.EthnicGroup
		,dem.UKBorn AS UkBorn
		,dem.BirthCountry
		,dem.UKEntryYear AS UkEntryYear
		,dem.SymptomOnset AS SymptomOnsetDate
		,dem.StartOfTreatment AS StartOfTreatmentDate
		,dem.DateOfDiagnosis AS DiagnosisDate
		,dem.DatePresented AS FirstPresentationDate
		,dem.SitePulmonary
		,dem.SiteBoneSpine
		,dem.SiteBoneOther
		,dem.SiteCNSMeningitis
		,dem.SiteCNSOther
		,dem.SiteCryptic
		,dem.SiteGI
		,dem.SiteGU
		,dem.SiteITLymphNodes
		,dem.SiteLymphNode
		,dem.SiteLaryngeal
		,dem.SiteMiliary
		,dem.SitePleural
		,dem.SiteNonPulmonaryOther
		,dem.SiteNonPulmonaryUnknown
		,dem.OtherExtraPulmonarySite
		,dem.SiteUnknown
		,dem.PreviouslyDiagnosed
		,dem.YearsSinceDiagnosis
		,dem.PreviouslyTreated
		,dem.TreatmentInUK AS TreatmentInUk
		,dem.PreviousId
		,dem.BcgVaccinated
		,dem.BcgVaccinationDate
		,dem.DrugUse AS DrugMisuse
		,dem.AlcoholUse AS AlcoholMisuse
		,dem.Homeless
		,dem.PrisonAtDiagnosis AS Prison
		,dem.PostMortemDiagnosis
		,dem.PostMortemDeathDate AS DateOfDeath
		,dem.DidNotStartTreatment
		,dem.MDRTreatment 
		,dem.MDRTreatmentDate AS MdrTreatmentDate
		,dem.ShortCourse
		,dem.DOT
		,NULL AS DOTOffered
		,NULL AS DOTReceived
		,dem.InPatient
		,dem.Comments
		,dem.TOMTreatmentInterruptedReason
		,dem.TOMTreatmentChangedReason
		,dem.TOMCompleteCourse
		,dem.TOMIncompleteReason
		,dem.TOMSubmittedDate
		,dem.TOMFollowUpResult
		,dem.TOMDeathDate
		,dem.TOMDeathRelationship
		,dem.TOMEndOfTreatmentDate
		,dem.TOMTreatmentRegimen
		,dem.TOMNonTuberculousMycobacteria
		,dem.TOMConversion
		,dem.TOMComment
		,dem.TOMReasonExceeds12mths
		,dem.TOMReported12mth
		,dem.TOMTreatmentInterruptedReason24mth
		,dem.TOMTreatmentChangedReason24mth
		,dem.TOMCompleteCourse24mth
		,dem.TOMIncompleteReason24mth
		,dem.TOMSubmittedDate24mth
		,dem.TOMFollowUpResult24mth
		,dem.TOMDeathDate24mth
		,dem.TOMDeathRelationship24mth
		,dem.TOMEndOfTreatmentDate24mth
		,dem.TOMTreatmentRegimen24mth
		,dem.TOMNonTuberculousMycobacteria24mth
		,dem.TOMConversion24mth
		,dem.TOMComment24mth
		,dem.TOMReported24mth
		,dem.TreatementRegion AS TreatmentRegion
		,dem.TreatementHPU AS TreatmentHPU
		,dem.HospitalName
		,dem.HospitalPCT
		,dem.HospitalLocalAuthority
		,dem.ResolvedResidenceHPU
		,dem.ResolvedResidenceRegion
		,dem.ResolvedResidenceLA
		,CASE dem.NoFixedAbode
			WHEN 0 THEN 'FALSE'
			ELSE 'TRUE'
			END AS NoFixedAbode
		,dem.HIVTestOffered AS HivTestOffered
		,dem.NoSampleTaken
		,dem.ProposedDrugRegimen
		,NULL AS TreatmentRegimen
		,dem.CurrentDrugUse AS CurrentDrugMisuse
		,dem.DrugUseLast5Years AS DrugMisuseInLast5Years
		,dem.DrugUseMoreThan5YearsAgo AS DrugMisuseMoreThan5YearsAgo
		,dem.CurrentlyHomeless
		,dem.HomelessLast5Years AS HomelessInLast5Years
		,dem.HomelessMoreThan5YearsAgo
		,dem.CurrentlyInprisonOrWhenFirstSeen AS CurrentlyInPrisonOrInPrisonWhenFirstSeen
		,dem.PrisonLast5Years AS InPrisonInLast5Years
		,dem.PrisonAbroadLast5Years
		,dem.PrisonMoreThan5YearsAgo AS InPrisonMoreThan5YearsAgo
		,dem.PrisonAbroadMoreThan5YearsAgo
		,dem.TravelledOutsideUK AS TravelledOutsideUk
		,dem.ToHowManyCountries
		,dem.TravelCountry1
		,dem.[DurationofTravel1(Months)] AS MonthsTravelled1
		,dem.TravelCountry2
		,dem.[DurationofTravel2(Months)] AS MonthsTravelled2
		,dem.TravelCountry3
		,dem.[DurationofTravel3(Months)] AS MonthsTravelled3
		,dem.ReceivedVisitors
		,dem.FromHowManyCountries
		,dem.VisitorCountry1
		,dem.[DurationVisitorsStayed1(Months)] AS MonthsVisitorsStayed1
		,dem.VisitorCountry2
		,dem.[DurationVisitorsStayed2 (Months)] AS MonthsVisitorsStayed2
		,dem.VisitorCountry3
		,dem.[DurationVisitorsStayed3 (Months)] AS MonthsVisitorsStayed3
		,dem.Diabetes
		,dem.HepB AS HepatitisB
		,dem.HepC AS HepatitisC
		,dem.ChronicLiverDisease
		,dem.ChronicRenalDisease
		,dem.ImmunoSuppression
		,dem.AntiTNFATreatment AS BiologicalTherapy
		,dem.Transplantation
		,dem.Other AS OtherImmunoSuppression
		,dem.OtherComments AS ImmunosuppressionComments
		,dem.Smoker AS CurrentSmoker
		,dem.AdultContactsIdentified
		,dem.ChildContactsIdentified
		,dem.TotalContactsIdentified
		,dem.AdultContactsAssessed
		,dem.ChildContactsAssessed
		,dem.TotalContactsAssessed
		,dem.AdultContactsActiveTB
		,dem.ChildContactsActiveTB
		,dem.TotalContactsActiveTB
		,dem.AdultContactsLTBI
		,dem.ChildContactsLTBI
		,dem.TotalContactsLTBI
		,dem.AdultContactsLTBITreat
		,dem.ChildContactsLTBITreat
		,dem.TotalContactsLTBITreat
		,dem.AdultContactsLTBITreatComplete
		,dem.ChildContactsLTBITreatComplete
		,dem.TotalContactsLTBITreatComplete
		,dem.TOMTreatmentInterruptedReason36mth
		,dem.TOMTreatmentChangedReason36mth
		,dem.TOMCompleteCourse36mth
		,dem.TOMIncompleteReason36mth
		,dem.TOMSubmittedDate36mth
		,dem.TOMFollowUpResult36mth
		,dem.TOMDeathDate36mth
		,dem.TOMDeathRelationship36mth
		,dem.TOMEndOfTreatmentDate36mth
		,dem.TOMTreatmentRegimen36mth
		,dem.TOMNonTuberculousMycobacteria36mth
		,dem.TOMConversion36mth
		,dem.TOMComment36mth
		,dem.TOMReported36mth
		,dem.TOMReasonExceeds24mths
		,dem.WorldRegionName
		,rr.SourceSystem
		,rr.NotificationDate
		,rr.TBServiceCode
		,rr.ResidencePhecCode
		,rr.TreatmentPhecCode
	
	FROM [$(ETS)].[dbo].[DataExportMainTable] dem
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = dem.Id AND rr.SourceSystem = 'ETS'
