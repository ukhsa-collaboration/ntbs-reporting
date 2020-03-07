/***************************************************************************************************
Desc:	This populates ReusableNotification with every record in ReusableNotification_ETS whose 
		ETS ID is not already in ReusableNotification along with every record in NTBS         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotification]
AS

TRUNCATE TABLE ReusableNotification

--Initial code to populate from NTBS, currently just a select statement

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
	,h.[Name]										AS 'Hospital'
	,hd.TBServiceCode								AS 'TBServiceCode'
	,tbs.[Name]										AS 'Service'
	,p.NhsNumber									AS 'NhsNumber' 
	,p.GivenName									AS 'Forename'
	,p.FamilyName									AS 'Surname'
	,CONVERT(DATE, p.Dob) 							AS 'DateOfBirth' 
	,dbo.ufnGetAgefrom(p.Dob,n.NotificationDate)	AS 'Age' 
	,s.Label										AS 'Sex' 
	,dbo.ufnYesNo(p.UkBorn)							AS 'UKBorn'
	,e.Label										AS 'EthnicGroup'
	,c.[Name]										AS 'BirthCountry'
	,p.YearOfUkEntry								AS 'UkEntryYear'
	,p.Postcode										AS 'Postcode' 
	,dbo.ufnYesNo(p.NoFixedAbode)					AS 'NoFixedAbode'
	,la.[Name]										AS 'LocalAuthority'
	,la.Code										AS 'LocalAuthorityCode'
	,resphec.Code									AS 'ResidencePhecCode' 
	,resphec.[Name]									AS 'ResidencePhec'
	,treatphec.Code									AS 'TreatmentPhecCode'
	,treatphec.[Name]								AS 'TreatmentPhec'
	--clinical dates are next. We will want to extend these to include the additional dates captured in NTBS
	,cd.SymptomStartDate							AS 'SymptomOnsetDate'
	,cd.TBServicePresentationDate					AS 'PresentedDate' --TODO: check this is what the date in ETS refers to, as we have two presentation dates now
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
	,ct.AdultsIdentified + ct.ChildrenIdentified	AS 'TotalContactsIdentified'
	,ct.AdultsScreened								AS 'AdultContactsAssessed'
	,ct.ChildrenScreened							AS 'ChildContactsAssessed'
	,ct.AdultsScreened + ct.ChildrenScreened		AS 'TotalContactsAssessed'
	,ct.AdultsActiveTB								AS 'AdultContactsActiveTB'
	,ct.ChildrenActiveTB							AS 'ChildContactsActiveTB'
	,ct.AdultsActiveTB + ct.ChildrenActiveTB		AS 'TotalContactsActiveTB'
	,ct.AdultsLatentTB								AS 'AdultContactsLTBI'
	,ct.ChildrenLatentTB							AS 'ChildContactsLTBI'
	,ct.AdultsLatentTB + ct.ChildrenLatentTB		AS 'TotalContactsLTBI'
	,ct.AdultsStartedTreatment						AS 'AdultContactsLTBITreat'
	,ct.ChildrenStartedTreatment					AS 'ChildContactsLTBITreat'
	,ct.AdultsStartedTreatment + 
		ct.ChildrenStartedTreatment					AS 'TotalContactsLTBITreat'
	,ct.AdultsFinishedTreatment						AS 'AdultContactsLTBITreatComplete'
	,ct.ChildrenFinishedTreatment					AS 'ChildContactsLTBITreatComplete'
	,ct.AdultsFinishedTreatment + 
		ct.ChildrenFinishedTreatment				AS 'TotalContactsLTBITreatComplete'
	--non-NTBS Diagnosis
	,dbo.ufnYesNo(pth.PreviouslyHadTB)				AS 'PreviouslyDiagnosed' 
	,DATEDIFF(pth.PreviousTBDiagnosisYear, 
        n.NotificationDate)					        AS 'YearsSinceDiagnosis' 
	,NULL											AS 'PreviouslyTreated' --we aren't capturing this in NTBS, a mistake?
	,NULL											AS 'TreatmentInUK' --ditto
	,NULL											AS 'PreviousId' --not relevant to NTBS as this dataset is for non-NTBS cases
	,cd.BCGVaccinationState							AS 'BcgVaccinated' --NB: this data item is about to change in NTBS
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
	--TODO: is there a better way to do this than just joining to the country table 6 or 7 times? A function?
	,dbo.ufnYesNo(td.HasTravel)						AS 'TravelledOutsideUk'
	,td.TotalNumberOfCountries						AS 'ToHowManyCountries'
	,c1.[Name]										AS 'TravelCountry1'
	,td.StayLengthInMonths1							AS 'MonthsTravelled1'
	,c2.[Name]										AS 'TravelCountry2'
	,td.StayLengthInMonths2							AS 'MonthsTravelled2'
	,NULL											AS 'TravelCountry3' --TODO: waiting to see if a function would be better
	,td.StayLengthInMonths3							AS 'MonthsTravelled3'
	,dbo.ufnYesNo(vd.HasVisitor)					AS 'ReceivedVisitors'
	,vd.TotalNumberOfCountries						AS 'FromHowManyCountries'
	,NULL											AS 'VisitorCountry1'
	,vd.StayLengthInMonths1							AS 'DaysVisitorsStayed1' --NB is this captured in days in ETS? It's captured in months in NTBS
	,NULL											AS 'VisitorCountry2'
	,vd.StayLengthInMonths2							AS 'DaysVisitorsStayed2'
	,NULL											AS 'VisitorCountry3' --TODO: waiting to see if a function would be better
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
	,srf.SmokingStatus								AS 'CurrentSmoker' 
	--treatment details
	,dbo.ufnYesNo(cd.IsPostMortem)					AS 'PostMortemDiagnosis' 
	,dbo.ufnYesNo(cd.DidNotStartTreatment)			AS 'DidNotStartTreatment' 
    --TODO: the way this is stored in NTBS is about to change, see NTBS-890
	,NULL						                    AS 'ShortCourse' 
	,NULL							                AS 'MdrTreatment' 
	,cd.MDRTreatmentStartDate						AS 'MdrTreatmentDate' 
	--Outcomes
	--Done in a separate function later on
	,NULL											AS 'TreatmentOutcome12months'
	,NULL											AS 'TreatmentOutcome24months'
	,NULL											AS 'TreatmentOutcome36months'
	,NULL											AS 'LastRecordedTreatmentOutcome'
	--dates
	--date of death can be fetched from the Treatment Event table, even though for post-mortem it will also be stored on clinical details. This is one consistent way to obtain it
	,NULL											AS 'DateOfDeath'
	--TODO:this will need to be the date of an 'ending' event, assuming there is no 'starting' event after it
	,NULL											AS 'TreatmentEndDate'
	,dbo.ufnYesNo (ted.HasTestCarriedOut)			AS 'NoSampleTaken'
	--TEMPORARY WAY OF ADDING THESE TO QUERY - IN REALITY THESE WILL BE ADDED TO THE TABLE AFTER INSERTION
	,crs.CulturePositive							AS 'CulturePositive'
	,crs.Species									AS 'Species'
	,crs.EarliestSpecimenDate						AS 'EarliestSpecimenDate'
	,crs.DrugResistanceProfile						AS 'DrugResistanceProfile'
	,crs.INH										AS 'INH'
	,crs.RIF										AS 'RIF'
	,crs.ETHAM										AS 'EMB'
	,crs.PYR										AS 'PZA'
	,crs.AMINO										AS 'AMINO'
	,crs.QUIN										AS 'QUIN'
	,crs.MDR										AS 'MDR'
	,crs.XDR										AS 'XDR'
	,GETUTCDATE()									AS 'DataRefreshedAt'
	
	FROM [$(NTBS)].[dbo].[Notification] n
		LEFT OUTER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[User] u ON u.Username = hd.CaseManagerUsername
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Hospital] h ON h.HospitalId = hd.HospitalId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[TbService] tbs ON tbs.Code = hd.TBServiceCode
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Patients] p on p.NotificationId = n.NotificationId 
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Sex] s ON s.SexId = p.SexId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Ethnicity] e ON e.EthnicityId = p.EthnicityId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Country] c ON c.CountryId = p.CountryId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[PostcodeLookup] pl ON pl.Postcode = p.PostcodeToLookup
		LEFT OUTER JOIN [$(NTBS)].[dbo].[LocalAuthority] la ON pl.LocalAuthorityCode = la.Code
		LEFT OUTER JOIN [$(NTBS)].[dbo].[LocalAuthorityToPHEC] la2p ON la2p.LocalAuthorityCode = pl.LocalAuthorityCode
		LEFT OUTER JOIN [$(NTBS)].[dbo].[PHEC] resphec ON resphec.Code = la2p.PHECCode
		LEFT OUTER JOIN [$(NTBS)].[dbo].[PHEC] treatphec ON treatphec.Code = tbs.PHECCode
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ClinicalDetails] cd ON cd.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ContactTracing] ct ON ct.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[PatientTBHistories] pth ON pth.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[SocialRiskFactors] srf ON srf.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[RiskFactorDrugs] rfd ON rfd.SocialRiskFactorsNotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[RiskFactorHomelessness] rfh ON rfh.SocialRiskFactorsNotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[RiskFactorImprisonment] rfp ON rfp.SocialRiskFactorsNotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[TravelDetails] td ON td.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Country] c1 ON c1.CountryId = td.Country1Id
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Country] c2 ON c2.CountryId = td.Country2Id
		LEFT OUTER JOIN [$(NTBS)].[dbo].[VisitorDetails] vd ON vd.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ComorbidityDetails] cod ON cod.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[ImmunosuppressionDetails] id ON id.NotificationId = n.NotificationId
		LEFT OUTER JOIN [$(NTBS)].[dbo].[TestData] ted ON ted.NotificationId = n.NotificationId
		--TEMPORARY
		LEFT OUTER JOIN [dbo].[CultureAndResistanceSummary] crs ON crs.NotificationId = n.NotificationId
	WHERE n.NotificationStatus = 'Notified'

	UPDATE ReusableNotification 
	SET AnySocialRiskFactor = CASE WHEN AlcoholMisuse = 'Yes' OR 
										DrugMisuse = 'Yes' OR 
										Homeless = 'Yes' OR
										Prison = 'Yes' 
										THEN 'Yes' ELSE 'No' END  --do we want/are there any other scenarios?


    EXEC [dbo].uspGenerateReusableOutcome

    EXEC [dbo].uspGenerateReusableNotificationLastRecordedTreatmentOutcome
    
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
          ,rne.[DataRefreshedAt]  FROM [dbo].[ReusableNotification_ETS] rne
          LEFT OUTER JOIN [dbo].[ReusableNotification] rn ON rn.EtsId = rne.EtsId
	      WHERE rn.EtsId IS NULL
          --using a LEFT OUTER JOIN because 'NOT IN' doesn't cope with NULL values