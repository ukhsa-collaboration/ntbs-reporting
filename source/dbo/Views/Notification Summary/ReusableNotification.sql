﻿CREATE VIEW [dbo].[ReusableNotification]
	AS
	SELECT 
	  rr.RegisterId						AS ReusableNotificationId
	  ,rr.[NotificationId]
      ,CASE rr.SourceSystem WHEN 'NTBS' THEN rr.NotificationId ELSE NULL END AS [NtbsId]
      ,[EtsId]
      ,rr.[SourceSystem]
      ,[LtbrId]
      ,[NotificationDate]
      ,[CaseManager]
      ,[Consultant]
      ,[HospitalId]
      ,[Hospital]
      ,[TBServiceCode]
	  ,[TbService] AS [Service]
      ,[NhsNumber]
      ,[GivenName] AS [Forename]
      ,[FamilyName] AS [Surname]
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
      ,[Lat]
      ,[Long]
      ,[SymptomOnsetDate]
	  ,[FirstPresentationDate] AS [PresentedDate]
	  ,COALESCE(OnsetToFirstPresentationDays, 0) + COALESCE(FirstPresentationToReferralReceivedDays, 0) + COALESCE(ReferralReceivedToTbServiceFirstPresentationDays, 0) AS [OnsetToPresentationDays]
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
      ,rr.[ClusterId]
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
	  ,[MonthsVisitorsStayed1] AS [DaysVisitorsStayed1]
      ,[VisitorCountry2]
	  ,[MonthsVisitorsStayed2] AS [DaysVisitorsStayed2]
      ,[VisitorCountry3]
	  ,[MonthsVisitorsStayed3] AS [DaysVisitorsStayed3]
      ,[Diabetes]
      ,[HepatitisB]
      ,[HepatitisC]
      ,[ChronicLiverDisease]
      ,[ChronicRenalDisease]
      ,[ImmunoSuppression]
      ,[BiologicalTherapy]
      ,[Transplantation]
      ,[OtherImmunoSuppression]
      ,[Smoking] AS CurrentSmoker --we now have time periods in NTBS for smoking, so need to select the 'Yes/No' field rather than CurrentSmoker as previously
      ,[PostMortemDiagnosis]
      ,CASE [StartedTreatment]
        WHEN 'No' THEN 'Yes'
        WHEN 'Yes' THEN 'No'
        END                                     AS [DidNotStartTreatment]
      ,[TreatmentRegimen]
      ,[MdrTreatmentDate]
      ,[TreatmentOutcome12months]
      ,[TreatmentOutcome24months]
      ,[TreatmentOutcome36months]
      ,[LastRecordedTreatmentOutcome]
      ,[DateOfDeath]
      ,[TreatmentEndDate]
      ,CASE [SampleTaken] 
        WHEN  'Yes' THEN 'No' 
        WHEN 'No' THEN 'Yes' 
       END                                      AS NoSampleTaken
      ,car.CulturePositive 
      ,car.Species
      ,car.EarliestSpecimenDate
      ,car.DrugResistanceProfile
      ,car.INH
      ,car.RIF
      ,car.EMB
      ,car.PZA
      ,car.AMINO
      ,car.QUIN
      ,car.MDR
      ,car.XDR
      ,[DataRefreshedAt] 
  FROM [dbo].[RecordRegister] rr
	INNER JOIN [dbo].[Record_PersonalDetails] pd ON pd.NotificationId = rr.NotificationId
	INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = rr.NotificationId
    INNER JOIN [dbo].[Record_CultureAndResistance] car ON car.NotificationId = rr.NotificationId
WHERE rr.Denotified = 0 

