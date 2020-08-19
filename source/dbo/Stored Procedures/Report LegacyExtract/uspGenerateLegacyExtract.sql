CREATE PROCEDURE [dbo].[uspGenerateLegacyExtract]
	
AS
	BEGIN TRY
		
		--fields which are already in ReusableNotification have been moved over already
		--now to update those which only live in the LegacyExtract
		UPDATE [dbo].[LegacyExtract]
			SET LocalPatientId = COALESCE(p.LocalPatientId, ''),
			AddressLine1 = COALESCE(p.[Address], ''),
			AddressLine2 = '',
			Town = '',
			County = '',
			BcgVaccinationDate = COALESCE(CONVERT(NVARCHAR(5), cd.BCGVaccinationYear), ''),
			DOT = [dbo].ufnGetLegacyDOTvalue(cd.DotStatus),
			InPatient = 'Not known',
			OtherExtraPulmonarySite = COALESCE(ns.[SiteDescription], ''),
			Comments = COALESCE(LEFT(cd.Notes, 500), ''),
			HIVTestOffered =  [dbo].[ufnGetHIVValue](cd.HIVTestState),
			ProposedDrugRegimen = '',
			ImmunosuppressionComments = COALESCE(id.OtherDescription, ''),
			PCT = COALESCE(pl.PctCode, ''),
			HospitalPCT = COALESCE(h.pctName, ''),
			HospitalLocalAuthority = COALESCE(la.[Name], ''),
			WorldRegionName = continent.[Name]
			FROM 
				[$(NTBS)].[dbo].[Patients] p
				INNER JOIN [$(NTBS)].[dbo].[ClinicalDetails] cd ON cd.NotificationId = p.NotificationId
				INNER JOIN [$(NTBS)].[dbo].[ImmunosuppressionDetails] id ON id.NotificationId = p.NotificationId
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] pl ON pl.Pcode = REPLACE(p.Postcode, ' ', '')
				INNER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = p.NotificationId
				LEFT OUTER JOIN [$(NTBS)].[dbo].[NotificationSite] ns ON ns.NotificationId = p.NotificationId AND ns.SiteId = 17
				LEFT OUTER JOIN [$(ETS)].[dbo].[Hospital] h ON h.Id = hd.HospitalId
				LEFT OUTER JOIN [$(ETS)].[dbo].[LocalAuthority] la ON la.Code = h.LocalAuthorityCode
				INNER JOIN [$(NTBS)].[ReferenceData].Country c ON c.CountryId = p.CountryId
				LEFT OUTER JOIN [$(ETS)].[dbo].[Country] c2 ON c2.IsoCode = c.IsoCode
				LEFT OUTER JOIN [$(ETS)].[dbo].[Continent] continent ON continent.Id = c2.ContinentId
				INNER JOIN [dbo].[LegacyExtract] le1 ON le1.NotificationId = p.NotificationId AND le1.SourceSystem = 'NTBS'

	
		--second pass to derive HPU from PCT
	
		UPDATE [dbo].[LegacyExtract]
			SET HPU = COALESCE(nacs.HPU, ''),
            ResolvedResidenceHPU = COALESCE(nacs.HPU, '')
			FROM [$(ETS)].[dbo].[NACS_pctlookup] nacs
			RIGHT OUTER JOIN [dbo].[LegacyExtract] le1 ON le1.PCT = nacs.PCT_code

		EXEC [dbo].[uspUpdateLegacySitesOfDisease]

		--now move over the records from ETS where the notification hasn't been migrated into NTBS

		INSERT INTO [dbo].[LegacyExtract]
           ([NotificationId]
           ,[SourceSystem]
           ,[IDOriginal]
           ,[LocalPatientId]
           ,[CaseReportDate]
           ,[ReportYear]
           ,[Denotified]
           ,[DenotificationDate]
           ,[DenotificationComments]
           ,[CaseManager]
           ,[Hospital]
           ,[PatientsConsultant]
           ,[Title]
           ,[Forename]
           ,[Surname]
           ,[NHSNumber]
           ,[Sex]
           ,[Age]
           ,[DateOfBirth]
           ,[AddressLine1]
           ,[AddressLine2]
           ,[Town]
           ,[County]
           ,[Postcode]
           ,[PCT]
           ,[HPU]
           ,[LocalAuthority]
           ,[Region]
           ,[Occupation]
           ,[OccupationCategory]
           ,[EthnicGroup]
           ,[UKBorn]
           ,[BirthCountry]
           ,[UKEntryYear]
           ,[SymptomOnset]
           ,[StartOfTreatment]
           ,[DateOfDiagnosis]
           ,[DatePresented]
           ,[SitePulmonary]
           ,[SiteBoneSpine]
           ,[SiteBoneOther]
           ,[SiteCNSMeningitis]
           ,[SiteCNSOther]
           ,[SiteCryptic]
           ,[SiteGI]
           ,[SiteGU]
           ,[SiteITLymphNodes]
           ,[SiteLymphNode]
           ,[SiteLaryngeal]
           ,[SiteMiliary]
           ,[SitePleural]
           ,[SiteNonPulmonaryOther]
           ,[SiteNonPulmonaryUnknown]
           ,[OtherExtraPulmonarySite]
           ,[SiteUnknown]
           ,[PreviouslyDiagnosed]
           ,[YearsSinceDiagnosis]
           ,[PreviouslyTreated]
           ,[TreatmentInUK]
           ,[PreviousId]
           ,[BcgVaccinated]
           ,[BcgVaccinationDate]
           ,[DrugUse]
           ,[AlcoholUse]
           ,[Homeless]
           ,[Prison]
           ,[PostMortemDiagnosis]
           ,[PostMortemDeathDate]
           ,[DidNotStartTreatment]
           ,[MDRTreatment]
           ,[MDRTreatmentDate]
           ,[ShortCourse]
           ,[DOT]
           ,[InPatient]
           ,[Comments]
           ,[TOMTreatmentInterruptedReason]
           ,[TOMTreatmentChangedReason]
           ,[TOMCompleteCourse]
           ,[TOMIncompleteReason]
           ,[TOMSubmittedDate]
           ,[TOMFollowUpResult]
           ,[TOMDeathDate]
           ,[TOMDeathRelationship]
           ,[TOMEndOfTreatmentDate]
           ,[TOMTreatmentRegimen]
           ,[TOMNonTuberculousMycobacteria]
           ,[TOMConversion]
           ,[TOMComment]
           ,[TOMReasonExceeds12mths]
           ,[TOMReported12mth]
           ,[TOMTreatmentInterruptedReason24mth]
           ,[TOMTreatmentChangedReason24mth]
           ,[TOMCompleteCourse24mth]
           ,[TOMIncompleteReason24mth]
           ,[TOMSubmittedDate24mth]
           ,[TOMFollowUpResult24mth]
           ,[TOMDeathDate24mth]
           ,[TOMDeathRelationship24mth]
           ,[TOMEndOfTreatmentDate24mth]
           ,[TOMTreatmentRegimen24mth]
           ,[TOMNonTuberculousMycobacteria24mth]
           ,[TOMConversion24mth]
           ,[TOMComment24mth]
           ,[TOMReported24mth]
           ,[TreatmentRegion]
           ,[TreatmentHPU]
           ,[HospitalName]
           ,[HospitalPCT]
           ,[HospitalLocalAuthority]
           ,[ResolvedResidenceHPU]
           ,[ResolvedResidenceRegion]
           ,[ResolvedResidenceLA]
           ,[NoFixedAbode]
           ,[HIVTestOffered]
           ,[NoSampleTaken]
           ,[ProposedDrugRegimen]
           ,[CurrentDrugUse]
           ,[DrugUseLast5Years]
           ,[DrugUseMoreThan5YearsAgo]
           ,[CurrentlyHomeless]
           ,[HomelessLast5Years]
           ,[HomelessMoreThan5YearsAgo]
           ,[CurrentlyInprisonOrWhenFirstSeen]
           ,[PrisonLast5Years]
           ,[PrisonAbroadLast5Years]
           ,[PrisonMoreThan5YearsAgo]
           ,[PrisonAbroadMoreThan5YearsAgo]
           ,[TravelledOutsideUK]
           ,[ToHowManyCountries]
           ,[TravelCountry1]
           ,[DurationofTravel1(Months)]
           ,[TravelCountry2]
           ,[DurationofTravel2(Months)]
           ,[TravelCountry3]
           ,[DurationofTravel3(Months)]
           ,[ReceivedVisitors]
           ,[FromHowManyCountries]
           ,[VisitorCountry1]
           ,[DurationVisitorsStayed1]
           ,[VisitorCountry2]
           ,[DurationVisitorsStayed2]
           ,[VisitorCountry3]
           ,[DurationVisitorsStayed3]
           ,[Diabetes]
           ,[HepB]
           ,[HepC]
           ,[ChronicLiverDisease]
           ,[ChronicRenalDisease]
           ,[ImmunoSuppression]
           ,[BiologicalTherapy]
           ,[Transplantation]
           ,[ImmunosuppressionOther]
           ,[ImmunosuppressionComments]
           ,[CurrentSmoker]
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
           ,[TOMTreatmentInterruptedReason36mth]
           ,[TOMTreatmentChangedReason36mth]
           ,[TOMCompleteCourse36mth]
           ,[TOMIncompleteReason36mth]
           ,[TOMSubmittedDate36mth]
           ,[TOMFollowUpResult36mth]
           ,[TOMDeathDate36mth]
           ,[TOMDeathRelationship36mth]
           ,[TOMEndOfTreatmentDate36mth]
           ,[TOMTreatmentRegimen36mth]
           ,[TOMNonTuberculousMycobacteria36mth]
           ,[TOMConversion36mth]
           ,[TOMComment36mth]
           ,[TOMReported36mth]
           ,[TOMReasonExceeds24mths]
           ,[WorldRegionName])

           SELECT
            dm.Id
            ,'ETS'
            ,dm.IDOriginal
            ,dm.LocalPatientId
            ,dm.CaseReportDate
            ,NULL--ReportYear
            ,dm.Denotified
            ,dm.DenotificationDate
            ,dm.DenotificationComments
            ,dm.CaseManager
            ,dm.Hospital
            ,dm.PatientsConsultant
            ,dm.Title
            ,dm.Forename
            ,dm.Surname
            ,dm.NHSNumber
            ,dm.Sex
            ,dm.Age
            ,dm.DateOfBirth
            ,dm.AddressLine1
            ,dm.AddressLine2
            ,dm.Town
            ,dm.county
            ,dm.Postcode
            ,dm.PCT
            ,dm.HPU
            ,dm.LocalAuthority
            ,dm.Region
            ,dm.Occupation
            ,dm.OccupationCategory
            ,dm.EthnicGroup
            ,dm.UKBorn
            ,dm.BirthCountry
            ,dm.UKEntryYear
            ,dm.SymptomOnset
            ,dm.StartOfTreatment
            ,dm.DateOfDiagnosis
            ,dm.DatePresented
            ,dm.SitePulmonary
            ,dm.SiteBoneSpine
            ,dm.SiteBoneOther
            ,dm.SiteCNSMeningitis
            ,dm.SiteCNSOther
            ,dm.SiteCryptic
            ,dm.SiteGI
            ,dm.SiteGU
            ,dm.SiteITLymphNodes
            ,dm.SiteLymphNode
            ,dm.SiteLaryngeal
            ,dm.SiteMiliary
            ,dm.SitePleural
            ,dm.SiteNonPulmonaryOther
            ,dm.SiteNonPulmonaryUnknown
            ,dm.OtherExtraPulmonarySite
            ,dm.SiteUnknown
            ,dm.PreviouslyDiagnosed
            ,dm.YearsSinceDiagnosis
            ,dm.PreviouslyTreated
            ,dm.TreatmentInUK
            ,dm.PreviousId
            ,dm.BcgVaccinated
            ,dm.BcgVaccinationDate
            ,dm.DrugUse
            ,dm.AlcoholUse
            ,dm.Homeless
            ,NULL--dm.Prison work out which field this is in the ETS table
            ,dm.PostMortemDiagnosis
            ,dm.PostMortemDeathDate
            ,dm.DidNotStartTreatment
            ,dm.MDRTreatment
            ,dm.MDRTreatmentDate
            ,dm.ShortCourse
            ,dm.DOT
            ,dm.InPatient
            ,dm.Comments
            ,dm.TOMTreatmentInterruptedReason
            ,dm.TOMTreatmentChangedReason
            ,dm.TOMCompleteCourse
            ,dm.TOMIncompleteReason
            ,dm.TOMSubmittedDate
            ,dm.TOMFollowUpResult
            ,dm.TOMDeathDate
            ,dm.TOMDeathRelationship
            ,dm.TOMEndOfTreatmentDate
            ,dm.TOMTreatmentRegimen
            ,dm.TOMNonTuberculousMycobacteria
            ,dm.TOMConversion
            ,dm.TOMComment
            ,dm.TOMReasonExceeds12mths
            ,dm.TOMReported12mth
            ,dm.TOMTreatmentInterruptedReason24mth
            ,dm.TOMTreatmentChangedReason24mth
            ,dm.TOMCompleteCourse24mth
            ,dm.TOMIncompleteReason24mth
            ,dm.TOMSubmittedDate24mth
            ,dm.TOMFollowUpResult24mth
            ,dm.TOMDeathDate24mth
            ,dm.TOMDeathRelationship24mth
            ,dm.TOMEndOfTreatmentDate24mth
            ,dm.TOMTreatmentRegimen24mth
            ,dm.TOMNonTuberculousMycobacteria24mth
            ,dm.TOMConversion24mth
            ,dm.TOMComment24mth
            ,dm.TOMReported24mth
            ,dm.TreatementRegion
            ,dm.TreatementHPU
            ,dm.HospitalName
            ,dm.HospitalPCT
            ,dm.HospitalLocalAuthority
            ,dm.ResolvedResidenceHPU
            ,dm.ResolvedResidenceRegion
            ,dm.ResolvedResidenceLA
            ,dm.NoFixedAbode
            ,dm.HIVTestOffered
            ,dm.NoSampleTaken
            ,dm.ProposedDrugRegimen
            ,dm.CurrentDrugUse
            ,dm.DrugUseLast5Years
            ,dm.DrugUseMoreThan5YearsAgo
            ,dm.CurrentlyHomeless
            ,dm.HomelessLast5Years
            ,dm.HomelessMoreThan5YearsAgo
            ,dm.CurrentlyInprisonOrWhenFirstSeen
            ,dm.PrisonLast5Years
            ,dm.PrisonAbroadLast5Years
            ,dm.PrisonMoreThan5YearsAgo
            ,dm.PrisonAbroadMoreThan5YearsAgo
            ,dm.TravelledOutsideUK
            ,dm.ToHowManyCountries
            ,dm.TravelCountry1
            ,dm.[DurationofTravel1(Months)]
            ,dm.TravelCountry2
            ,dm.[DurationofTravel2(Months)]
            ,dm.TravelCountry3
            ,dm.[DurationofTravel3(Months)]
            ,dm.ReceivedVisitors
            ,dm.FromHowManyCountries
            ,dm.VisitorCountry1
            ,dm.[DurationVisitorsStayed1(Months)]
            ,dm.VisitorCountry2
            ,dm.[DurationVisitorsStayed2 (Months)]
            ,dm.VisitorCountry3
            ,dm.[DurationVisitorsStayed3 (Months)]
            ,dm.Diabetes
            ,dm.HepB
            ,dm.HepC
            ,dm.ChronicLiverDisease
            ,dm.ChronicRenalDisease
            ,dm.ImmunoSuppression
            ,dm.AntiTNFATreatment AS 'BiologicalTherapy'
            ,dm.Transplantation
            ,dm.Other AS 'ImmunosuppressionOther'
            ,dm.OtherComments AS 'ImmunosuppressionComments'
            ,dm.Smoker AS 'CurrentSmoker'
            ,ct.AdultContactsIdentified
            ,ct.ChildContactsIdentified
            ,ct.TotalContactsIdentified
            ,ct.AdultContactsAssessed
            ,ct.ChildContactsAssessed
            ,ct.TotalContactsAssessed
            ,ct.AdultContactsActiveTB
            ,ct.ChildContactsActiveTB
            ,ct.TotalContactsActiveTB
            ,ct.AdultContactsLTBI
            ,ct.ChildContactsLTBI
            ,ct.TotalContactsLTBI
            ,ct.AdultContactsLTBITreat
            ,ct.ChildContactsLTBITreat
            ,ct.TotalContactsLTBITreat
            ,ct.AdultContactsLTBITreatComplete
            ,ct.ChildContactsLTBITreatComplete
            ,ct.TotalContactsLTBITreatComplete
            ,dm.TOMTreatmentInterruptedReason36mth
            ,dm.TOMTreatmentChangedReason36mth
            ,dm.TOMCompleteCourse36mth
            ,dm.TOMIncompleteReason36mth
            ,dm.TOMSubmittedDate36mth
            ,dm.TOMFollowUpResult36mth
            ,dm.TOMDeathDate36mth
            ,dm.TOMDeathRelationship36mth
            ,dm.TOMEndOfTreatmentDate36mth
            ,dm.TOMTreatmentRegimen36mth
            ,dm.TOMNonTuberculousMycobacteria36mth
            ,dm.TOMConversion36mth
            ,dm.TOMComment36mth
            ,dm.TOMReported36mth
            ,dm.TOMReasonExceeds24mths
            ,dm.WorldRegionName

           FROM [$(ETS)].[dbo].[DataExportMainTable] dm
            INNER JOIN [$(ETS)].[dbo].[Notification] n ON n.Id = dm.Guid
            LEFT OUTER JOIN [$(ETS)].[dbo].[ContactTracing] ct ON ct.Id = n.ContactTracingId
            WHERE dm.Id IN (SELECT NotificationId FROM [dbo].[ReusableNotification] WHERE SourceSystem = 'ETS')

	END TRY
	BEGIN CATCH
		THROW
	END CATCH

RETURN 0
