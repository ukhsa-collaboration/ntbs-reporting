/***************************************************************************************************
Desc:	This populates ReusableNotification with every record in ReusableNotification_ETS whose 
		ETS ID is not already in ReusableNotification along with every record in NTBS         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotification]
AS

SET NOCOUNT ON

BEGIN TRY
	TRUNCATE TABLE ReusableNotification

	DECLARE @IncludeNTBS BIT = (SELECT TOP(1) IncludeNTBS FROM [dbo].[ReportingFeatureFlags])
	IF @IncludeNTBS = 1
	--only include NTBS records if NTBS is live.  
	BEGIN
		INSERT INTO ReusableNotification ([NotificationId]
			  ,[NtbsId]
			  ,[EtsId]
			  ,[SourceSystem]
			  ,[LtbrId]
			  ,[NotificationDate]
			  ,[CaseManager]
			  ,[Consultant]
			  ,[HospitalId]
			  ,[Hospital]
			  ,[TBServiceCode]
			  ,[Service]
			  ,[NhsNumber]
			  ,[Forename]
			  ,[Surname]
			  ,[DateOfBirth]
			  ,[Age]
			  ,[Sex]
			  ,[UkBorn]
			  ,[EthnicGroup]
			  ,[Occupation]
			  ,[OccupationCategory]
			  ,[BirthCountry]
			  ,[UkEntryYear]
			  ,[Postcode]
			  ,[NoFixedAbode]
			  ,[LocalAuthority]
			  ,[LocalAuthorityCode]
			  ,[ResidencePhecCode]
			  ,[ResidencePhec]
			  ,[TreatmentPhecCode]
			  ,[TreatmentPhec]
			  ,[SymptomOnsetDate]
			  ,[PresentedDate]
			  ,[OnsetToPresentationDays]
			  ,[DiagnosisDate]
			  ,[PresentationToDiagnosisDays]
			  ,[StartOfTreatmentDate]
			  ,[DiagnosisToTreatmentDays]
			  ,[OnsetToTreatmentDays]
			  ,[HivTestOffered]
			  ,[SiteOfDisease]
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
			  ,[DaysVisitorsStayed1]
			  ,[VisitorCountry2]
			  ,[DaysVisitorsStayed2]
			  ,[VisitorCountry3]
			  ,[DaysVisitorsStayed3]
			  ,[Diabetes]
			  ,[HepatitisB]
			  ,[HepatitisC]
			  ,[ChronicLiverDisease]
			  ,[ChronicRenalDisease]
			  ,[ImmunoSuppression]
			  ,[BiologicalTherapy]
			  ,[Transplantation]
			  ,[OtherImmunoSuppression]
			  ,[CurrentSmoker]
			  ,[PostMortemDiagnosis]
			  ,[DidNotStartTreatment]
			  ,[ShortCourse]
			  ,[MdrTreatment]
			  ,[MdrTreatmentDate]
			  ,[TreatmentOutcome12months]
			  ,[TreatmentOutcome24months]
			  ,[TreatmentOutcome36months]
			  ,[LastRecordedTreatmentOutcome]
			  ,[DateOfDeath]
			  ,[TreatmentEndDate]
			  ,[NoSampleTaken]
			  ,[CulturePositive]
			  ,[Species]
			  ,[EarliestSpecimenDate]
			  ,[DrugResistanceProfile]
			  ,[INH]
			  ,[RIF]
			  ,[EMB]
			  ,[PZA]
			  ,[AMINO]
			  ,[QUIN]
			  ,[MDR]
			  ,[XDR]
			  ,[DataRefreshedAt]) 
		SELECT 
			n.NotificationId								AS 'NotificationId'
			,n.NotificationId								AS 'NTBS_ID'
			,n.ETSID										AS 'EtsId'
			,'NTBS'											AS 'SourceSystem'
			,n.LTBRID										AS 'LtbrId'
			,CONVERT(DATE, n.NotificationDate)				AS 'NotificationDate' 
			,u.DisplayName									AS 'CaseManager'
			,hd.Consultant									AS 'Consultant'
			,hd.HospitalId									AS 'HospitalID'
			,h.[HospitalName]								AS 'Hospital'
			,hd.TBServiceCode								AS 'TBServiceCode'
			,tbs.TB_Service_Name							AS 'Service'
			,p.NhsNumber									AS 'NhsNumber' 
			,p.GivenName									AS 'Forename'
			,p.FamilyName									AS 'Surname'
			,CONVERT(DATE, p.Dob) 							AS 'DateOfBirth' 
			,dbo.ufnGetAgefrom(p.Dob,n.NotificationDate)	AS 'Age' 
			,s.[Label]										AS 'Sex' 
			,dbo.ufnYesNo(p.UkBorn)							AS 'UKBorn'
			,e.[Label]										AS 'EthnicGroup'
			,(CASE 
				WHEN occ.HasFreeTextField = 1 THEN p.OccupationOther
				ELSE occ.[Role]	
			 END)											AS 'Occupation'
			,occ.[Sector]									AS 'OccupationCategory'
			,dbo.ufnGetCountryName(p.CountryId)			    AS 'BirthCountry'
			,p.YearOfUkEntry								AS 'UkEntryYear'
			,p.Postcode										AS 'Postcode' 
			,dbo.ufnYesNo(p.NoFixedAbode)					AS 'NoFixedAbode'
			,la.LA_Name										AS 'LocalAuthority'
			,la.LA_Code										AS 'LocalAuthorityCode'
			,resphec.PHEC_Code								AS 'ResidencePhecCode' 
			,COALESCE(resphec.PHEC_Name, 'Unknown')			AS 'ResidencePhec'
			,treatphec.PHEC_Code							AS 'TreatmentPhecCode'
			,COALESCE(treatphec.PHEC_Name, 'Unknown')		AS 'TreatmentPhec'
			--clinical dates are next. We will want to extend these to include the additional dates captured in NTBS
			,cd.SymptomStartDate							AS 'SymptomOnsetDate'
			,cd.FirstPresentationDate					    AS 'PresentedDate' 
			,CAST((DATEDIFF(DAY,
							cd.SymptomStartDate, 
							cd.TBServicePresentationDate))
						AS SMALLINT)						AS 'OnsetToPresentationDays' 
			,cd.DiagnosisDate								AS 'DiagnosisDate'
			,CAST((DATEDIFF(DAY,
							cd.TBServicePresentationDate, 
							cd.DiagnosisDate))
						AS SMALLINT)						AS 'PresentationToDiagnosisDays' 
			,cd.TreatmentStartDate							AS 'StartOfTreatmentDate'
			,CAST((DATEDIFF(DAY,
							cd.DiagnosisDate, 
							cd.TreatmentStartDate))
						AS SMALLINT)						AS 'DiagnosisToTreatmentDays' 
			,CAST((DATEDIFF(DAY,
							cd.SymptomStartDate, 
							cd.TreatmentStartDate))
						AS SMALLINT)						AS 'OnsetToTreatmentDays' 
			,dbo.ufnGetHivTestOffered (cd.HIVTestState)		AS 'HivTestOffered' 
			--NEXT: need to join to NotificationSite and Site tables to summarise site of disease
			,dbo.ufnGetSiteOfDisease(n.NotificationId)		AS 'SiteOfDisease' -- New function created for this. To be checked.
			--Contact Tracing
			,ct.AdultsIdentified							AS 'AdultContactsIdentified'
			,ct.ChildrenIdentified							AS 'ChildContactsIdentified'
			,[dbo].[ufnCalcContactTracingTotals](ct.AdultsIdentified, ct.ChildrenIdentified)	
															AS 'TotalContactsIdentified'
			,ct.AdultsScreened								AS 'AdultContactsAssessed'
			,ct.ChildrenScreened							AS 'ChildContactsAssessed'
			,[dbo].[ufnCalcContactTracingTotals]
				(ct.AdultsScreened, ct.ChildrenScreened)	AS 'TotalContactsAssessed'
			,ct.AdultsActiveTB								AS 'AdultContactsActiveTB'
			,ct.ChildrenActiveTB							AS 'ChildContactsActiveTB'
			,[dbo].[ufnCalcContactTracingTotals]
				(ct.AdultsActiveTB, ct.ChildrenActiveTB)	AS 'TotalContactsActiveTB'
			,ct.AdultsLatentTB								AS 'AdultContactsLTBI'
			,ct.ChildrenLatentTB							AS 'ChildContactsLTBI'
			,[dbo].[ufnCalcContactTracingTotals]
				(ct.AdultsLatentTB, ct.ChildrenLatentTB)	AS 'TotalContactsLTBI'
			,ct.AdultsStartedTreatment						AS 'AdultContactsLTBITreat'
			,ct.ChildrenStartedTreatment					AS 'ChildContactsLTBITreat'
			,[dbo].[ufnCalcContactTracingTotals](ct.AdultsStartedTreatment, ct.ChildrenStartedTreatment)				
															AS 'TotalContactsLTBITreat'
			,ct.AdultsFinishedTreatment						AS 'AdultContactsLTBITreatComplete'
			,ct.ChildrenFinishedTreatment					AS 'ChildContactsLTBITreatComplete'
			,[dbo].[ufnCalcContactTracingTotals](ct.AdultsFinishedTreatment,ct.ChildrenFinishedTreatment)			
															AS 'TotalContactsLTBITreatComplete'
			--non-NTBS Diagnosis
			,pth.PreviouslyHadTb            				AS 'PreviouslyDiagnosed' 
			,DATEPART(YEAR, n.NotificationDate)-
				pth.PreviousTbDiagnosisYear				    AS 'YearsSinceDiagnosis' 
			,pth.PreviouslyTreated							AS 'PreviouslyTreated'
			,(CASE 
				WHEN ptc.IsoCode = 'GB' THEN 'Yes'
				WHEN ptc.IsoCode IS NOT NULL THEN 'No'
				ELSE NULL
			END)		            						AS 'TreatmentInUK'
			,NULL											AS 'PreviousId' --not relevant to NTBS as this dataset is for non-NTBS cases
			,cd.BCGVaccinationState							AS 'BcgVaccinated' 
			--social risk factors
			-- we have additional ones in NTBS for asylym seeker and immigration detainee, smoker (currently in co-morbid) and mental health
			,NULL											AS 'AnySocialRiskFactor' -- updated at end
			,srf.AlcoholMisuseStatus						AS 'AlcoholMisuse' 
			,rfd.[Status]									AS 'DrugMisuse' 
			,dbo.ufnYesNo(rfd.IsCurrent)					AS 'CurrentDrugMisuse'
			,dbo.ufnYesNo(rfd.InPastFiveYears)				AS 'DrugMisuseInLast5Years'
			,dbo.ufnYesNo(rfd.MoreThanFiveYearsAgo)			AS 'DrugMisuseMoreThan5YearsAgo'
			,rfh.[Status]									AS 'Homeless'
			,dbo.ufnYesNo(rfh.IsCurrent)					AS 'CurrentlyHomeless'
			,dbo.ufnYesNo(rfh.InPastFiveYears)				AS 'HomelessInLast5Years'
			,dbo.ufnYesNo(rfh.MoreThanFiveYearsAgo)			AS 'HomelessMoreThan5YearsAgo'
			,rfp.[Status]									AS 'Prison'
			,dbo.ufnYesNo(rfp.IsCurrent)					AS 'CurrentlyInPrisonOrInPrisonWhenFirstSeen'
			,dbo.ufnYesNo(rfp.InPastFiveYears)				AS 'InPrisonInLast5Years'
			,dbo.ufnYesNo(rfp.MoreThanFiveYearsAgo)			AS 'InPrisonMoreThan5YearsAgo'
			--travel and visitors
			,td.HasTravel									AS 'TravelledOutsideUk'
			,td.TotalNumberOfCountries						AS 'ToHowManyCountries'
			,dbo.ufnGetCountryName(td.Country1Id)			AS 'TravelCountry1'
			,td.StayLengthInMonths1							AS 'MonthsTravelled1'
			,dbo.ufnGetCountryName(td.Country2Id)			AS 'TravelCountry2'
			,td.StayLengthInMonths2							AS 'MonthsTravelled2'
			,dbo.ufnGetCountryName(td.Country3Id)			AS 'TravelCountry3' 
			,td.StayLengthInMonths3							AS 'MonthsTravelled3'
			,vd.HasVisitor									AS 'ReceivedVisitors'
			,vd.TotalNumberOfCountries						AS 'FromHowManyCountries'
			,dbo.ufnGetCountryName(vd.Country1Id)			AS 'VisitorCountry1'
			,vd.StayLengthInMonths1							AS 'DaysVisitorsStayed1' --NB is this captured in days in ETS? It's captured in months in NTBS
			,dbo.ufnGetCountryName(vd.Country2Id)			AS 'VisitorCountry2'
			,vd.StayLengthInMonths2							AS 'DaysVisitorsStayed2'
			,dbo.ufnGetCountryName(vd.Country3Id)			AS 'VisitorCountry3' 
			,vd.StayLengthInMonths3							AS 'DaysVisitorsStayed3'
			--comorbidities
			,cod.DiabetesStatus								AS 'Diabetes' 
			,cod.HepatitisBStatus							AS 'HepatitisB'
			,cod.HepatitisCStatus							AS 'HepatitisC' 
			,cod.LiverDiseaseStatus							AS 'ChronicLiverDisease'
			,cod.RenalDiseaseStatus							AS 'ChronicRenalDisease'
			,id.[Status]									AS 'ImmunoSuppression'
			,dbo.ufnYesNo(id.HasBioTherapy)					AS 'BiologicalTherapy'
			,dbo.ufnYesNo(id.HasTransplantation)			AS 'Transplantation' 
			,dbo.ufnYesNo(id.HasOther)						AS 'OtherImmunoSuppression'
			,rfs.[Status]                                   AS 'CurrentSmoker'
			--treatment details
			,dbo.ufnYesNo(cd.IsPostMortem)					AS 'PostMortemDiagnosis' 
			,dbo.ufnYesNo(cd.DidNotStartTreatment)			AS 'DidNotStartTreatment' 
			--next two fields set in separate function later on
			,NULL						                    AS 'ShortCourse' 
			,NULL							                AS 'MdrTreatment' 
			,cd.MDRTreatmentStartDate						AS 'MdrTreatmentDate' 
			--Outcomes are done in a separate function later on
			,NULL											AS 'TreatmentOutcome12months'
			,NULL											AS 'TreatmentOutcome24months'
			,NULL											AS 'TreatmentOutcome36months'
			,NULL											AS 'LastRecordedTreatmentOutcome'
			--dates
			--date of death fetched from the Treatment Event table
			,dbo.ufnGetDateOfDeath(n.NotificationId)		AS 'DateOfDeath'
			,dbo.ufnGetTreatmentEndDate(n.NotificationId)	AS 'TreatmentEndDate'
			--need to reverse the value stored in NTBS as the question is phrased as 'Has Test Carried Out'
			--so 1 means yes, a test was carried out, and should be stored in the reporting service as No
			--in answer to the question 'No Sample Taken'
			,(CASE 
				WHEN ted.HasTestCarriedOut = 1 THEN 'No'
				WHEN ted.HasTestCarriedOut = 0 THEN 'Yes'
				ELSE ''
			  END)											AS 'NoSampleTaken'
			,NULL               							AS 'CulturePositive'
			,NULL									        AS 'Species'
			,NULL						                    AS 'EarliestSpecimenDate'
			,NULL						                    AS 'DrugResistanceProfile'
			,NULL										    AS 'INH'
			,NULL										    AS 'RIF'
			,NULL										    AS 'EMB'
			,NULL										    AS 'PZA'
			,NULL										    AS 'AMINO'
			,NULL										    AS 'QUIN'
			,NULL										    AS 'MDR'
			,NULL										    AS 'XDR'
			,GETUTCDATE()									AS 'DataRefreshedAt'
	
			FROM [$(NTBS)].[dbo].[Notification] n
				LEFT OUTER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = n.NotificationId
				LEFT OUTER JOIN [$(NTBS)].[dbo].[User] u ON u.Username = hd.CaseManagerUsername
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h ON h.HospitalId = hd.HospitalId
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs ON tbs.TB_Service_Code = hd.TBServiceCode
				LEFT OUTER JOIN [$(NTBS)].[dbo].[Patients] p on p.NotificationId = n.NotificationId 
				LEFT OUTER JOIN [$(NTBS)].[ReferenceData].Occupation occ ON occ.OccupationId = p.OccupationId
				LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[Sex] s ON s.SexId = p.SexId
				LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[Ethnicity] e ON e.EthnicityId = p.EthnicityId
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] pl ON pl.Pcode = REPLACE(p.Postcode, ' ', '')
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Local_Authority] la ON la.LA_Code = pl.LA_Code
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[LA_to_PHEC] la2p ON la2p.LA_Code = pl.LA_Code
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] resphec ON resphec.PHEC_Code = la2p.PHEC_Code
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbs2p ON tbs2p.TB_Service_Code = hd.TBServiceCode
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] treatphec ON treatphec.PHEC_Code = tbs2p.PHEC_Code
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
			--NTBS-1535: Include Denotified records temporarily
			WHERE n.NotificationStatus IN ('Notified', 'Closed', 'Denotified')
			AND (n.ClusterId IS NOT NULL OR YEAR(n.NotificationDate) IN (SELECT NotificationYear FROM vwNotificationYear))

			UPDATE ReusableNotification 
			SET AnySocialRiskFactor = CASE WHEN AlcoholMisuse = 'Yes' OR 
												DrugMisuse = 'Yes' OR 
												Homeless = 'Yes' OR
												Prison = 'Yes' 
												THEN 'Yes' ELSE 'No' END  --TODO: do we want/are there any other scenarios?

			EXEC [dbo].uspGenerateReusableNotificationTreatmentRegimen                                  

			EXEC [dbo].uspGenerateReusableOutcome

			EXEC [dbo].uspGenerateReusableNotificationLastRecordedTreatmentOutcome

			EXEC [dbo].uspNotificationCultureResistanceSummary
		END
    
    --now add the records from the ReusableNotification_ETS table which aren't already in the ReusableNotification table
    --these will be ETS records within the reporting time period (currently 2016 onwards) which haven't been migrated into NTBS
    INSERT INTO ReusableNotification ([NotificationId]
          ,[NtbsId]
          ,[EtsId]
          ,[SourceSystem]
          ,[LtbrId]
          ,[NotificationDate]
          ,[CaseManager]
          ,[Consultant]
          ,[HospitalId]
          ,[Hospital]
          ,[TBServiceCode]
          ,[Service]
          ,[NhsNumber]
          ,[Forename]
          ,[Surname]
          ,[DateOfBirth]
          ,[Age]
          ,[Sex]
          ,[UkBorn]
          ,[EthnicGroup]
		  ,[Occupation]
		  ,[OccupationCategory]
          ,[BirthCountry]
          ,[UkEntryYear]
          ,[Postcode]
          ,[NoFixedAbode]
          ,[LocalAuthority]
          ,[LocalAuthorityCode]
          ,[ResidencePhecCode]
          ,[ResidencePhec]
          ,[TreatmentPhecCode]
          ,[TreatmentPhec]
          ,[SymptomOnsetDate]
          ,[PresentedDate]
          ,[OnsetToPresentationDays]
          ,[DiagnosisDate]
          ,[PresentationToDiagnosisDays]
          ,[StartOfTreatmentDate]
          ,[DiagnosisToTreatmentDays]
          ,[OnsetToTreatmentDays]
          ,[HivTestOffered]
          ,[SiteOfDisease]
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
          ,[DaysVisitorsStayed1]
          ,[VisitorCountry2]
          ,[DaysVisitorsStayed2]
          ,[VisitorCountry3]
          ,[DaysVisitorsStayed3]
          ,[Diabetes]
          ,[HepatitisB]
          ,[HepatitisC]
          ,[ChronicLiverDisease]
          ,[ChronicRenalDisease]
          ,[ImmunoSuppression]
          ,[BiologicalTherapy]
          ,[Transplantation]
          ,[OtherImmunoSuppression]
          ,[CurrentSmoker]
          ,[PostMortemDiagnosis]
          ,[DidNotStartTreatment]
          ,[ShortCourse]
          ,[MdrTreatment]
          ,[MdrTreatmentDate]
          ,[TreatmentOutcome12months]
          ,[TreatmentOutcome24months]
          ,[TreatmentOutcome36months]
          ,[LastRecordedTreatmentOutcome]
          ,[DateOfDeath]
          ,[TreatmentEndDate]
          ,[NoSampleTaken]
          ,[CulturePositive]
          ,[Species]
          ,[EarliestSpecimenDate]
          ,[DrugResistanceProfile]
          ,[INH]
          ,[RIF]
          ,[EMB]
          ,[PZA]
          ,[AMINO]
          ,[QUIN]
          ,[MDR]
          ,[XDR]
          ,[DataRefreshedAt]) 
    SELECT	rne.[NotificationId]
          ,rne.[NtbsId]
          ,rne.[EtsId]
          ,rne.[SourceSystem]
          ,rne.[LtbrId]
          ,rne.[NotificationDate]
          ,rne.[CaseManager]
          ,rne.[Consultant]
          ,rne.[HospitalId]
          ,rne.[Hospital]
          ,rne.[TBServiceCode]
          ,rne.[Service]
          ,rne.[NhsNumber]
          ,rne.[Forename]
          ,rne.[Surname]
          ,rne.[DateOfBirth]
          ,rne.[Age]
          ,rne.[Sex]
          ,rne.[UkBorn]
          ,rne.[EthnicGroup]
		  ,rne.[Occupation]
		  ,rne.[OccupationCategory]
          ,rne.[BirthCountry]
          ,rne.[UkEntryYear]
          ,rne.[Postcode]
          ,rne.[NoFixedAbode]
          ,rne.[LocalAuthority]
          ,rne.[LocalAuthorityCode]
          ,rne.[ResidencePhecCode]
          ,rne.[ResidencePhec]
          ,rne.[TreatmentPhecCode]
          ,rne.[TreatmentPhec]
          ,rne.[SymptomOnsetDate]
          ,rne.[PresentedDate]
          ,rne.[OnsetToPresentationDays]
          ,rne.[DiagnosisDate]
          ,rne.[PresentationToDiagnosisDays]
          ,rne.[StartOfTreatmentDate]
          ,rne.[DiagnosisToTreatmentDays]
          ,rne.[OnsetToTreatmentDays]
          ,rne.[HivTestOffered]
          ,rne.[SiteOfDisease]
          ,rne.[AdultContactsIdentified]
          ,rne.[ChildContactsIdentified]
          ,rne.[TotalContactsIdentified]
          ,rne.[AdultContactsAssessed]
          ,rne.[ChildContactsAssessed]
          ,rne.[TotalContactsAssessed]
          ,rne.[AdultContactsActiveTB]
          ,rne.[ChildContactsActiveTB]
          ,rne.[TotalContactsActiveTB]
          ,rne.[AdultContactsLTBI]
          ,rne.[ChildContactsLTBI]
          ,rne.[TotalContactsLTBI]
          ,rne.[AdultContactsLTBITreat]
          ,rne.[ChildContactsLTBITreat]
          ,rne.[TotalContactsLTBITreat]
          ,rne.[AdultContactsLTBITreatComplete]
          ,rne.[ChildContactsLTBITreatComplete]
          ,rne.[TotalContactsLTBITreatComplete]
          ,rne.[PreviouslyDiagnosed]
          ,rne.[YearsSinceDiagnosis]
          ,rne.[PreviouslyTreated]
          ,rne.[TreatmentInUk]
          ,rne.[PreviousId]
          ,rne.[BcgVaccinated]
          ,rne.[AnySocialRiskFactor]
          ,rne.[AlcoholMisuse]
          ,rne.[DrugMisuse]
          ,rne.[CurrentDrugMisuse]
          ,rne.[DrugMisuseInLast5Years]
          ,rne.[DrugMisuseMoreThan5YearsAgo]
          ,rne.[Homeless]
          ,rne.[CurrentlyHomeless]
          ,rne.[HomelessInLast5Years]
          ,rne.[HomelessMoreThan5YearsAgo]
          ,rne.[Prison]
          ,rne.[CurrentlyInPrisonOrInPrisonWhenFirstSeen]
          ,rne.[InPrisonInLast5Years]
          ,rne.[InPrisonMoreThan5YearsAgo]
          ,rne.[TravelledOutsideUk]
          ,rne.[ToHowManyCountries]
          ,rne.[TravelCountry1]
          ,rne.[MonthsTravelled1]
          ,rne.[TravelCountry2]
          ,rne.[MonthsTravelled2]
          ,rne.[TravelCountry3]
          ,rne.[MonthsTravelled3]
          ,rne.[ReceivedVisitors]
          ,rne.[FromHowManyCountries]
          ,rne.[VisitorCountry1]
          ,rne.[DaysVisitorsStayed1]
          ,rne.[VisitorCountry2]
          ,rne.[DaysVisitorsStayed2]
          ,rne.[VisitorCountry3]
          ,rne.[DaysVisitorsStayed3]
          ,rne.[Diabetes]
          ,rne.[HepatitisB]
          ,rne.[HepatitisC]
          ,rne.[ChronicLiverDisease]
          ,rne.[ChronicRenalDisease]
          ,rne.[ImmunoSuppression]
          ,rne.[BiologicalTherapy]
          ,rne.[Transplantation]
          ,rne.[OtherImmunoSuppression]
          ,rne.[CurrentSmoker]
          ,rne.[PostMortemDiagnosis]
          ,rne.[DidNotStartTreatment]
          ,rne.[ShortCourse]
          ,rne.[MdrTreatment]
          ,rne.[MdrTreatmentDate]
          ,rne.[TreatmentOutcome12months]
          ,rne.[TreatmentOutcome24months]
          ,rne.[TreatmentOutcome36months]
          ,rne.[LastRecordedTreatmentOutcome]
          ,rne.[DateOfDeath]
          ,rne.[TreatmentEndDate]
          ,rne.[NoSampleTaken]
          ,rne.[CulturePositive]
          ,rne.[Species]
          ,rne.[EarliestSpecimenDate]
          ,rne.[DrugResistanceProfile]
          ,rne.[INH]
          ,rne.[RIF]
          ,rne.[EMB]
          ,rne.[PZA]
          ,rne.[AMINO]
          ,rne.[QUIN]
          ,rne.[MDR]
          ,rne.[XDR]
          ,rne.[DataRefreshedAt]  
		  FROM [dbo].[ReusableNotification_ETS] rne
          LEFT OUTER JOIN [dbo].[ReusableNotification] rn ON rn.EtsId = rne.EtsId
	      WHERE rn.EtsId IS NULL
          --using a LEFT OUTER JOIN because 'NOT IN' doesn't cope with NULL values


		  
		  EXEC [dbo].[uspMoveRecordsToLegacyExtract]

	END TRY
	BEGIN CATCH
		THROW
	END CATCH