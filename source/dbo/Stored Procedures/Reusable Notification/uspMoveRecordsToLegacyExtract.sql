/***************************************************************************************************
Desc:	We have added denotified records into the ReusableNotification tables so that they can go through 
		the same transformation logic as the notified records. However, they are only needed for the
		LegacyExtract report and should not remain in the main table after processing
**************************************************************************************************/
CREATE PROCEDURE [dbo].[uspMoveRecordsToLegacyExtract]
	
AS
BEGIN TRY

    DELETE FROM [dbo].[LegacyExtract]

    --first add the NTBS records
	INSERT INTO [dbo].[LegacyExtract]
	([NotificationId]
      ,[SourceSystem]
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
      ,[Postcode]
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
      ,[PreviouslyDiagnosed]
      ,[YearsSinceDiagnosis]
      ,[PreviouslyTreated]
      ,[TreatmentInUK]
      ,[BcgVaccinated]
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
      ,[TreatmentRegion]
      ,[HospitalName]
      ,[ResolvedResidenceRegion]
      ,[ResolvedResidenceLA]
      ,[NoFixedAbode]
      ,[NoSampleTaken]
      ,[CurrentDrugUse]
      ,[DrugUseLast5Years]
      ,[DrugUseMoreThan5YearsAgo]
      ,[CurrentlyHomeless]
      ,[HomelessLast5Years]
      ,[HomelessMoreThan5YearsAgo]
      ,[CurrentlyInprisonOrWhenFirstSeen]
      ,[PrisonLast5Years]
      ,[PrisonMoreThan5YearsAgo]
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
	  ,[TbService])
  
	SELECT 
        rn.NotificationId                                                           AS 'NotificationId'
        ,rn.[SourceSystem]                                                          AS 'SourceSystem'
        ,CONVERT(DATE, rn.NotificationDate)                     	                AS 'CaseReportDate'
        ,DATEPART(YEAR, rn.NotificationDate)		                                AS 'ReportYear'
        ,(CASE
            WHEN dn.DateOfDenotification IS NOT NULL THEN 'Yes'
            ELSE 'No'
         END)                                                                       AS 'Denotified' 
        ,CONVERT(DATE, dn.DateOfDenotification)                                     AS 'DenotificationDate'
        ,COALESCE(drm.ReasonOutputName, '')                                         AS 'DenotificationReason'
        ,COALESCE(rn.CaseManager, '')				                                AS 'CaseManager' 
	    ,COALESCE(rn.Hospital, '')					                                AS 'Hospital'
	    ,COALESCE(rn.Consultant, '')				                                AS 'PatientsConsultant'
        ,''                                                                         AS 'Title'
        ,COALESCE(rn.Forename, '')					                                AS 'Forename'
	    ,COALESCE(rn.Surname, '')					                                AS 'Surname'
	    ,COALESCE(rn.NhsNumber, '')					                                AS 'NHSNumber'
	    ,LEFT(rn.Sex, 1)							                                AS 'Sex'
	    ,rn.Age										                                AS 'Age'
        ,FORMAT(rn.DateOfBirth, 'dd/MM/yyyy')		                                AS 'DateOfBirth'
        ,COALESCE(rn.[Postcode], '')                                                AS 'Postcode'
        ,COALESCE(rn.LocalAuthority, '')			                                AS 'LocalAuthority'
	    ,rn.ResidencePhec							                                AS 'Region'
        ,COALESCE(rn.Occupation, '')				                                AS 'Occupation'
	    ,COALESCE(rn.OccupationCategory, '')		                                AS 'OccupationCategory'
	    ,rn.EthnicGroup								                                AS 'EthnicGroup'
	    ,rn.UkBorn									                                AS 'UKBorn'
        ,COALESCE(rn.BirthCountry, '')                                              AS 'BirthCountry'
	    ,rn.UkEntryYear                                 				            AS 'UKEntryYear'
	    ,COALESCE(FORMAT(rn.SymptomOnsetDate, 'dd/MM/yyyy'), '')	                AS 'SymptomOnsetDate'
	    ,COALESCE(FORMAT(rn.StartOfTreatmentDate, 'dd/MM/yyyy'), '')                AS 'StartOfTreatmentDate'
	    ,COALESCE(FORMAT(rn.DiagnosisDate, 'dd/MM/yyyy'), '')		                AS 'DateOfDiagnosis'
	    ,COALESCE(FORMAT(rn.PresentedDate, 'dd/MM/yyyy'), '')	                    AS 'DatePresented'
        ,COALESCE(rn.PreviouslyDiagnosed, '')		                                AS 'PreviouslyDiagnosed'
	    ,rn.YearsSinceDiagnosis                                    	                AS 'YearsSinceDiagnosis'
	    ,COALESCE(rn.PreviouslyTreated, '')			                                AS 'PreviouslyTreated'
	    ,COALESCE(rn.TreatmentInUk, '')				                                AS 'TreatmentInUK'
	    ,COALESCE(rn.BcgVaccinated, '')                                             AS 'BCGVaccinated'
        ,COALESCE(rn.DrugMisuse, '')                                                AS 'DrugUse'
	    ,COALESCE(rn.AlcoholMisuse, '')				                                AS 'AlcoholUse'
	    ,COALESCE(rn.Homeless, '')					                                AS 'Homeless'
	    ,COALESCE(rn.Prison, '')					                                AS 'Prison'
	     ,(CASE 
			WHEN rn.PostMortemDiagnosis = 'Yes' THEN 'Yes'
			ELSE 'No'
			END)              			                                            AS 'PostMortemDiagnosis'
	    ,(CASE 
		    WHEN rn.PostMortemDiagnosis = 'Yes' THEN FORMAT(rn.DateOfDeath, 'dd/MM/yyyy')								
		    ELSE ''
		    END)									                                AS 'PostMortemDeathDate'
	    ,COALESCE(rn.DidNotStartTreatment, '')		                                AS 'DidNotStartTreatment'
	    ,COALESCE(rn.MdrTreatment,'')				                                AS 'MDRTreatment' 
	    ,COALESCE(CONVERT(NVARCHAR(10),rn.MdrTreatmentDate), '')			        AS 'MDRTreatmentDate'
	    ,COALESCE(rn.ShortCourse, '')				                                AS 'ShortCourse'
        ,COALESCE(rn.TreatmentPhec, '')				                                AS 'TreatmentRegion'
	    ,COALESCE(rn.Hospital, '')					                                AS 'HospitalName'
        ,COALESCE(rn.ResidencePhec, '')				                                AS 'ResolvedResidenceRegion'
	    ,COALESCE(rn.LocalAuthority, '')			                                AS 'ResolvedResidenceLA'
	    ,(CASE
		    WHEN rn.NoFixedAbode = 'Yes' THEN 1
		    ELSE 0
		    END)									                                AS 'NoFixedAbode' --TRUE/FALSE
        ,(CASE
		    WHEN rn.NoSampleTaken = 'Yes' THEN 1
		    ELSE 0
		    END)			                                                        AS 'NoSampleTaken'
	    ,COALESCE(rn.CurrentDrugMisuse, '')			                                AS 'CurrentDrugUse'
	    ,COALESCE(rn.DrugMisuseInLast5Years, '')	                                AS 'DrugUseLast5Years'
	    ,COALESCE(rn.DrugMisuseMoreThan5YearsAgo, '')	                            AS 'DrugUseMoreThan5YearsAgo'
	    ,COALESCE(rn.CurrentlyHomeless, '')				                            AS 'CurrentlyHomeless'
	    ,COALESCE(rn.HomelessInLast5Years, '')		                                AS 'HomelessLast5Years'
	    ,COALESCE(rn.HomelessMoreThan5YearsAgo, '')				                    AS 'HomelessMoreThan5YearsAgo'
	    ,COALESCE(rn.CurrentlyInPrisonOrInPrisonWhenFirstSeen, '')	                AS 'CurrentlyInprisonOrWhenFirstSeen'
	    ,COALESCE(rn.InPrisonInLast5Years, '')					                    AS 'PrisonLast5Years'
	    ,COALESCE(rn.InPrisonMoreThan5YearsAgo, '')				                    AS 'PrisonMoreThan5YearsAgo'
        ,COALESCE(rn.TravelledOutsideUk, '')						                AS 'TravelledOutsideUK'
	    ,COALESCE(rn.ToHowManyCountries, '')						                AS 'ToHowManyCountries'
	    ,COALESCE(rn.TravelCountry1	, '')						                    AS 'TravelCountry1'
	    ,COALESCE(CONVERT(NVARCHAR(10),rn.MonthsTravelled1), '')					AS 'DurationofTravel1(Months)'
	    ,COALESCE(rn.TravelCountry2, '')							                AS 'TravelCountry2'
	    ,COALESCE(CONVERT(NVARCHAR(10),rn.MonthsTravelled2), '')					AS 'DurationofTravel2(Months)'
	    ,COALESCE(rn.TravelCountry3, '')							                AS 'TravelCountry3'
	    ,COALESCE(CONVERT(NVARCHAR(10),rn.MonthsTravelled3), '')					AS 'DurationofTravel3(Months)'
	    ,COALESCE(rn.ReceivedVisitors, '')						                    AS 'ReceivedVisitors'
	    ,COALESCE(rn.FromHowManyCountries, '')					                    AS 'FromHowManyCountries'
	    ,COALESCE(rn.VisitorCountry1, '')							                AS 'VisitorCountry1'
	    ,COALESCE(rn.DaysVisitorsStayed1, '')						                AS 'DurationVisitorsStayed1'
	    ,COALESCE(rn.VisitorCountry2, '')							                AS 'VisitorCountry2'
	    ,COALESCE(rn.DaysVisitorsStayed2, '')						                AS 'DurationVisitorsStayed2'
	    ,COALESCE(rn.VisitorCountry3, '')							                AS 'VisitorCountry3'
	    ,COALESCE(rn.DaysVisitorsStayed3, '')						                AS 'DurationVisitorsStayed3'
	    ,COALESCE(rn.Diabetes, '')								                    AS 'Diabetes'
	    ,COALESCE(rn.HepatitisB, '')								                AS 'HepB'
	    ,COALESCE(rn.HepatitisC, '')								                AS 'HepC'
	    ,COALESCE(rn.ChronicLiverDisease, '')						                AS 'ChronicLiverDisease'
	    ,COALESCE(rn.ChronicRenalDisease, '')						                AS 'ChronicRenalDisease'
	    ,COALESCE(rn.ImmunoSuppression, '')						                    AS 'Immunosuppression'
	    ,COALESCE(rn.BiologicalTherapy, '')						                    AS 'BiologicalTherapy'
	    ,COALESCE(rn.Transplantation, '')							                AS 'Transplantation'
	    ,COALESCE(rn.OtherImmunoSuppression, '')					                AS 'ImmunosuppressionOther'
	    ,COALESCE(rn.CurrentSmoker, '')							                    AS 'CurrentSmoker'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.AdultContactsIdentified), '')				AS 'AdultContactsIdentified'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.ChildContactsIdentified), '')				AS 'ChildContactsIdentified'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.TotalContactsIdentified), '')				AS 'TotalContactsIdentified'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.AdultContactsAssessed), '')				AS 'AdultContactsAssessed'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.ChildContactsAssessed), '')				AS 'ChildContactsAssessed'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.TotalContactsAssessed), '')				AS 'TotalContactsAssessed'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.AdultContactsActiveTB), '')				AS 'AdultContactsActiveTB'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.ChildContactsActiveTB), '')				AS 'ChildContactsActiveTB'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.TotalContactsActiveTB), '')				AS 'TotalContactsActiveTB'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.AdultContactsLTBI), '')					AS 'AdultContactsLTBI'
	    ,COALESCE(CONVERT(NVARCHAR(5), rn.ChildContactsLTBI), '')					AS 'ChildContactsLTBI'
	    ,COALESCE(CONVERT(NVARCHAR(5), rn.TotalContactsLTBI), '')					AS 'TotalContactsLTBI'
	    ,COALESCE(CONVERT(NVARCHAR(5), rn.AdultContactsLTBITreat), '')				AS 'AdultContactsLTBITreat'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.ChildContactsLTBITreat), '')				AS 'ChildContactsLTBITreat'
	    ,COALESCE(CONVERT(NVARCHAR(5), rn.TotalContactsLTBITreat), '')				AS 'TotalContactsLTBITreat'
	    ,COALESCE(CONVERT(NVARCHAR(5), rn.AdultContactsLTBITreatComplete), '')		AS 'AdultContactsLTBITreatComplete'
	    ,COALESCE(CONVERT(NVARCHAR(5), rn.ChildContactsLTBITreatComplete), '')		AS 'ChildContactsLTBITreatComplete'
	    ,COALESCE(CONVERT(NVARCHAR(5),rn.TotalContactsLTBITreatComplete), '')		AS 'TotalContactsLTBITreatComplete'
		,COALESCE(rn.[Service], '')													AS 'TbService'

	FROM
		[dbo].[ReusableNotification] rn
		INNER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = rn.NotificationId
			AND rn.SourceSystem = 'NTBS'
			AND n.NotificationStatus IN ('Notified', 'Closed', 'Denotified')
		LEFT OUTER JOIN [$(NTBS)].[dbo].[DenotificationDetails] dn ON dn.NotificationId = rn.NotificationId
		LEFT OUTER JOIN [dbo].[DenotificationReasonMapping] drm ON drm.Reason = dn.Reason

        
    --and then remove these records from the ReusableNotification table
    DELETE FROM [dbo].[ReusableNotification] WHERE NotificationId IN 
        (SELECT NotificationID FROM [dbo].[LegacyExtract] WHERE Denotified = 'Yes')
END TRY
BEGIN CATCH
	THROW
END CATCH


RETURN 0
