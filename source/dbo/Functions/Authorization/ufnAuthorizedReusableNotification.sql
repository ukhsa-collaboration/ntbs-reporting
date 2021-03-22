/***************************************************************************************************
Desc:    This executes the permission PHEC region restrictions on the notification records that get
         queried at run-time. Every "Line List" proc is to select from this (instead directly from the 
		 ReusableNotification table. The logic is that a notification gets shown to a PHEC user, if it 
		 belongs to their treatment or to their residence PHEC. This means thst, if the treatment and 
		 residence PHEC differ, the notification gets returned for both users of both PHEC regions.
		 Any report can then apply additional filtering based on the value of the "Region" and/or the 
		 "Treatment or residence" drop-down.
		 
		 
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnAuthorizedReusableNotification] (
	@LoginGroups VARCHAR(500)
)
	RETURNS TABLE
AS
RETURN
	-- Debugging
	-- DECLARE @LoginGroups VARCHAR(255) = '###Global.NIS.NTBS.LON###'

	-- Distinct is to avoid row duplication for when a notification has a different treatment and residence PHEC
	SELECT DISTINCT
		-- Primary key
		n.NotificationId,

		-- Demographics
		n.EtsId,
		n.LtbrId,
		n.NotificationDate,
		n.CaseManager,
		n.Consultant,
		n.Hospital,
		n.[Service],
		n.NhsNumber,
		n.Forename,
		n.Surname,
		n.DateOfBirth,
		n.Age,
		n.Sex,
		n.UkBorn,
		n.EthnicGroup,
		n.BirthCountry,
		n.UkEntryYear,
		n.Postcode,
		n.NoFixedAbode,

		-- Geographies
		n.LocalAuthority,
		n.LocalAuthorityCode,
		n.ResidencePhec,
		n.TreatmentPhec,

		-- Clinical Details
		n.SymptomOnsetDate,
		n.PresentedDate,
		n.OnsetToPresentationDays,
		n.DiagnosisDate,
		n.PresentationToDiagnosisDays,
		n.StartOfTreatmentDate,
		n.DiagnosisToTreatmentDays,
		n.OnsetToTreatmentDays,
		n.HivTestOffered,
		n.SiteOfDisease,
		n.AdultContactsIdentified,
		n.ChildContactsIdentified,
		n.TotalContactsIdentified,
		n.AdultContactsAssessed,
		n.ChildContactsAssessed,
		n.TotalContactsAssessed,
		n.AdultContactsActiveTB,
		n.ChildContactsActiveTB,
		n.TotalContactsActiveTB,
		n.AdultContactsLTBI,
		n.ChildContactsLTBI,
		n.TotalContactsLTBI,
		n.AdultContactsLTBITreat,
		n.ChildContactsLTBITreat,
		n.TotalContactsLTBITreat,
		n.AdultContactsLTBITreatComplete,
		n.ChildContactsLTBITreatComplete,
		n.TotalContactsLTBITreatComplete,
		n.PreviouslyDiagnosed,
		n.YearsSinceDiagnosis,
		n.PreviouslyTreated,
		n.TreatmentInUk,
		n.PreviousId,
		n.BcgVaccinated,
		
		-- Risk Factors
		n.AnySocialRiskFactor,
		n.AlcoholMisuse,
		n.DrugMisuse,
		n.CurrentDrugMisuse,
		n.DrugMisuseInLast5Years,
		n.DrugMisuseMoreThan5YearsAgo,
		n.Homeless,
		n.CurrentlyHomeless,
		n.HomelessInLast5Years,
		n.HomelessMoreThan5YearsAgo,
		n.Prison,
		n.CurrentlyInPrisonOrInPrisonWhenFirstSeen,
		n.InPrisonInLast5Years,
		n.InPrisonMoreThan5YearsAgo,
		n.TravelledOutsideUk,
		n.ToHowManyCountries,
		n.TravelCountry1,
		n.MonthsTravelled1,
		n.TravelCountry2,
		n.MonthsTravelled2,
		n.TravelCountry3,
		n.MonthsTravelled3,
		n.ReceivedVisitors,
		n.FromHowManyCountries,
		n.VisitorCountry1,
		n.DaysVisitorsStayed1,
		n.VisitorCountry2,
		n.DaysVisitorsStayed2,
		n.VisitorCountry3,
		n.DaysVisitorsStayed3,
		n.Diabetes,
		n.HepatitisB,
		n.HepatitisC,
		n.ChronicLiverDisease,
		n.ChronicRenalDisease,
		n.ImmunoSuppression,
		n.BiologicalTherapy,
		n.Transplantation,
		n.OtherImmunoSuppression,
		n.CurrentSmoker,
		
		-- Treatment
		n.PostMortemDiagnosis,
		n.DidNotStartTreatment,
		n.MdrTreatmentDate,
		n.TreatmentOutcome12months,
		n.TreatmentOutcome24months,
		n.TreatmentOutcome36months,
		n.LastRecordedTreatmentOutcome,
		n.DateOfDeath,
		n.TreatmentEndDate,
		
		-- Culture & Resistance
		n.NoSampleTaken,
		n.CulturePositive,
		n.Species,
		n.EarliestSpecimenDate,
		n.DrugResistanceProfile,
		n.INH,
		n.RIF,
		n.EMB,
		n.PZA,
		n.MDR,
		n.XDR
	FROM dbo.ReusableNotification n WITH (NOLOCK)
		INNER JOIN dbo.Phec p ON (p.PhecName = n.TreatmentPhec OR p.PhecName = n.ResidencePhec)
		Left Outer join TB_Service s on s.phecid = p.PhecId and s.TB_Service_Name = n.Service
		--For Regional user
		inner JOIN dbo.PhecAdGroup pa ON pa.PhecId = p.PhecId
		inner JOIN dbo.AdGroup ag ON ag.AdGroupId = pa.AdGroupId 
		--For Service user
		left outer join dbo.ServiceAdGroup sa on sa.ServiceId = s.Serviceid 
		left outer join dbo.AdGroup sag on sag.AdGroupId = sa.AdGroupId and sag.ADGroupType = 'S' and ag.ADGroupType = 'R'


	-- Permission restriction on either treatment or residence region.
	-- Further filtering needs to happen in the main query depending on 
	-- the "Either Residence or Treatment" drop-down option selected:
	WHERE CHARINDEX('###' + ag.AdGroupName + '###', @LoginGroups) != 0 or CHARINDEX('###' + sag.AdGroupName + '###', @LoginGroups) != 0
GO
