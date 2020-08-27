/***************************************************************************************************
Desc:    This serves the "Enhanced Line List", which returns every/most notification data point
         in detail, based on the user's permission & filtering preference. Every notification record
		 returned gets audited, whch means a log entry gets added for each user that views a notification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspLegacyExtract]
	(
		@NotificationYearFrom	INTEGER			=	-3,
		@NotificationMonthFrom	INTEGER			=	1,
		@NotificationYearTo		INTEGER			=	0,
		@NotificationMonthTo	INTEGER			=	1,
		@Region					VARCHAR(1000)	=	NULL,
		@AgeFrom				INTEGER			=	NULL,
		@AgeTo					INTEGER			=	NULL,
		@UKBorn					VARCHAR(3)		=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		--don't think I need this bit
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT
		--as this check is done in uspPhec/uspService
		-- Debugging
		-- EXEC master..xp_logevent 60000, @LoginGroups

		DECLARE @allowedRegions TABLE(PhecCode VARCHAR(20), PhecName VARCHAR(50), SortOrder INT)
		INSERT @allowedRegions
			EXEC [dbo].[uspPhec] ''

		--this check ensures that the list of regions passed into the query does not contain any values which aren't found in the list of regions
		--the user is a member of. If it returns empty, that means all values are present within the authorised list of regions (they do not need to
		--be the same, so if the user is a member of South East and London, but selects on London, the query will return empty)
		IF NOT EXISTS(
			SELECT VALUE FROM STRING_SPLIT(@Region, ',')
			EXCEPT
			SELECT PhecName FROM @allowedRegions)


		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
			DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
			DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
			DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo) -- Move end date to last day of month

			--find list of services the user can query in the given region. For regional/national staff, it will be all
			--for service users, just their own services
			DECLARE @allowedServices TABLE(ServiceId INT, TB_Service_Name VARCHAR(150))
				INSERT @allowedServices
				EXEC [dbo].[uspService] @Region
			

			-- If value is All then set to null  = null in where clause, otherwise set to filter value
			DECLARE @BornInUK	VARCHAR(3) = (CASE WHEN @UKBorn = 'All' THEN NULL ELSE @UKBorn END)
			

			DECLARE @ReusableNotification ReusableNotificationType

			INSERT INTO @ReusableNotification (NotificationId)
				SELECT
					NotificationId
				FROM [dbo].[LegacyExtract] le
				WHERE
					le.CaseReportDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					AND (@AgeFrom IS NULL OR le.Age IS NULL OR le.Age >= @AgeFrom)
					AND (@AgeTo IS NULL OR le.Age IS NULL OR le.Age <= @AgeTo)
					AND (@BornInUK IS NULL OR le.UkBorn = @BornInUK)
					AND (Region IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')) OR TreatmentRegion IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')))
					AND TbService IN 
						(SELECT TB_Service_Name FROM @allowedServices)
				


			-- Return data to client app
			SELECT
				le.[NtbsId]													AS 'NtbsId'
				,le.[EtsId]													AS 'Id'
				,le.[IDOriginal]											AS 'IDOriginal'
				,le.[LocalPatientId]										AS 'LocalPatientId'
				,le.[CaseReportDate]										AS 'CaseReportDate'
				,le.[ReportYear]											AS 'ReportYear'
				,le.[Denotified]											AS 'Denotified'
				,le.[DenotificationDate]									AS 'DenotificationDate'
				,le.[DenotificationComments]								AS 'DenotificationComments'
				,le.[CaseManager]											AS 'CaseManager'
				,le.[Hospital]												AS 'Hospital'
				,le.[PatientsConsultant]									AS 'PatientsConsultant'
				,le.[Title]													AS 'Title'
				,le.[Forename]                                              AS 'Forename'
				,le.[Surname]                                               AS 'Surname'
				,le.[NHSNumber]												AS 'NHSNumber'
				,le.[Sex]                                                   AS 'Sex'
				,le.[Age]                                                   AS 'Age'
				,le.[DateOfBirth]                                           AS 'DateOfBirth'
				,le.[AddressLine1]                                          AS 'AddressLine1'
				,le.[AddressLine2]                                          AS 'AddressLine2'
				,le.[Town]													AS 'Town'
				,le.[County]                                                AS 'county'
				,le.[Postcode]                                              AS 'Postcode'
				,le.[PCT]													AS 'PCT'
				,le.[HPU]													AS 'HPU'
				,le.[LocalAuthority]										AS 'LocalAuthority'
				,le.[Region]                                                AS 'Region'
				,le.[Occupation]                                            AS 'Occupation'
				,le.[OccupationCategory]                                    AS 'OccupationCategory'
				,le.[EthnicGroup]                                           AS 'EthnicGroup'
				,le.[UKBorn]                                                AS 'UKBorn'
				,le.[BirthCountry]                                          AS 'BirthCountry'
				,le.[UKEntryYear]                                           AS 'UKEntryYear'
				,le.[SymptomOnset]                                          AS 'SymptomOnset'
				,le.[StartOfTreatment]                                      AS 'StartOfTreatment'
				,le.[DateOfDiagnosis]										AS 'DateOfDiagnosis'
				,le.[DatePresented]                                         AS 'DatePresented'
				,le.[SitePulmonary]                                         AS 'SitePulmonary'
				,le.[SiteBoneSpine]                                         AS 'SiteBoneSpine'
				,le.[SiteBoneOther]                                         AS 'SiteBoneOther'
				,le.[SiteCNSMeningitis]										AS 'SiteCNSMeningitis'
				,le.[SiteCNSOther]											AS 'SiteCNSOther'
				,le.[SiteCryptic]											AS 'SiteCryptic'
				,le.[SiteGI]												AS 'SiteGI'
				,le.[SiteGU]												AS 'SiteGU'
				,le.[SiteITLymphNodes]										AS 'SiteITLymphNodes'
				,le.[SiteLymphNode]											AS 'SiteLymphNode'
				,le.[SiteLaryngeal]											AS 'SiteLaryngeal'
				,le.[SiteMiliary]											AS 'SiteMiliary'
				,le.[SitePleural]											AS 'SitePleural'
				,le.[SiteNonPulmonaryOther]									AS 'SiteNonPulmonaryOther'
				,le.[SiteNonPulmonaryUnknown]								AS 'SiteNonPulmonaryUnknown'
				,le.[OtherExtraPulmonarySite]								AS 'OtherExtraPulmonarySite'
				,le.[SiteUnknown]											AS 'SiteUnknown'
				,le.[PreviouslyDiagnosed]									AS 'PreviouslyDiagnosed'
				,le.[YearsSinceDiagnosis]									AS 'YearsSinceDiagnosis'
				,le.[PreviouslyTreated]										AS 'PreviouslyTreated'
				,le.[TreatmentInUK]											AS 'TreatmentInUK'
				,le.[PreviousId]											AS 'PreviousId'
				,le.[BcgVaccinated]											AS 'BcgVaccinated'
				,le.[BcgVaccinationDate]									AS 'BcgVaccinationDate'
				,le.[DrugUse]												AS 'DrugUse'
				,le.[AlcoholUse]											AS 'AlcoholUse'
				,le.[Homeless]												AS 'Homeless'
				,le.[Prison]												AS 'Prison'
				,le.[PostMortemDiagnosis]									AS 'PostMortemDiagnosis'
				,le.[PostMortemDeathDate]									AS 'PostMortemDeathDate'
				,le.[DidNotStartTreatment]									AS 'DidNotStartTreatment'
				,le.[MDRTreatment]											AS 'MDRTreatment'
				,le.[MDRTreatmentDate]										AS 'MDRTreatmentDate'
				,le.[ShortCourse]											AS 'ShortCourse'
				,le.[DOT]													AS 'DOT'
				,le.[InPatient]												AS 'InPatient'
				,le.[Comments]												AS 'Comments'
				,le.[TOMTreatmentInterruptedReason]                         AS 'TOMTreatmentInterruptedReason'
				,le.[TOMTreatmentChangedReason]								AS 'TOMTreatmentChangedReason'
				,le.[TOMCompleteCourse]										AS 'TOMCompleteCourse'
				,le.[TOMIncompleteReason]									AS 'TOMIncompleteReason'
				,le.[TOMSubmittedDate]										AS 'TOMSubmittedDate'
				,le.[TOMFollowUpResult]										AS 'TOMFollowUpResult'
				,le.[TOMDeathDate]											AS 'TOMDeathDate'
				,le.[TOMDeathRelationship]									AS 'TOMDeathRelationship'
				,le.[TOMEndOfTreatmentDate]									AS 'TOMEndOfTreatmentDate'
				,le.[TOMTreatmentRegimen]									AS 'TOMTreatmentRegimen'
				,le.[TOMNonTuberculousMycobacteria]                         AS 'TOMNonTuberculousMycobacteria'
				,le.[TOMConversion]											AS 'TOMConversion'
				,le.[TOMComment]											AS 'TOMComment'
				,le.[TOMReasonExceeds12mths]								AS 'TOMReasonExceeds12mths'
				,le.[TOMReported12mth]										AS 'TOMReported12mth'
				,le.[TOMTreatmentInterruptedReason24mth]                    AS 'TOMTreatmentInterruptedReason24mth'
				,le.[TOMTreatmentChangedReason24mth]                        AS 'TOMTreatmentChangedReason24mth'
				,le.[TOMCompleteCourse24mth]								AS 'TOMCompleteCourse24mth'
				,le.[TOMIncompleteReason24mth]								AS 'TOMIncompleteReason24mth'
				,le.[TOMSubmittedDate24mth]									AS 'TOMSubmittedDate24mth'
				,le.[TOMFollowUpResult24mth]								AS 'TOMFollowUpResult24mth'
				,le.[TOMDeathDate24mth]										AS 'TOMDeathDate24mth'
				,le.[TOMDeathRelationship24mth]								AS 'TOMDeathRelationship24mth'
				,le.[TOMEndOfTreatmentDate24mth]							AS 'TOMEndOfTreatmentDate24mth'
				,le.[TOMTreatmentRegimen24mth]								AS 'TOMTreatmentRegimen24mth'
				,le.[TOMNonTuberculousMycobacteria24mth]                    AS 'TOMNonTuberculousMycobacteria24mth'
				,le.[TOMConversion24mth]									AS 'TOMConversion24mth'
				,le.[TOMComment24mth]										AS 'TOMComment24mth'
				,le.[TOMReported24mth]										AS 'TOMReported24mth'
				,le.[TreatmentRegion]										AS 'TreatmentRegion'
				,le.[TreatmentHPU]											AS 'TreatmentHPU'
				,le.[HospitalName]											AS 'HospitalName'
				,le.[HospitalPCT]											AS 'HospitalPCT'
				,le.[HospitalLocalAuthority]								AS 'HospitalLocalAuthority'
				,le.[ResolvedResidenceHPU]									AS 'ResolvedResidenceHPU'
				,le.[ResolvedResidenceRegion]								AS 'ResolvedResidenceRegion'
				,le.[ResolvedResidenceLA]									AS 'ResolvedResidenceLA'
				,le.[NoFixedAbode]											AS 'NoFixedAbode'
				,le.[HIVTestOffered]										AS 'HIVTesting'
				,le.[NoSampleTaken]											AS 'NoSampleTaken'
				,le.[ProposedDrugRegimen]									AS 'ProposedDrugRegimen'
				,le.[CurrentDrugUse]										AS 'CurrentDrugUse'
				,le.[DrugUseLast5Years]										AS 'DrugUseLast5Years'
				,le.[DrugUseMoreThan5YearsAgo]								AS 'DrugUseMoreThan5YearsAgo'
				,le.[CurrentlyHomeless]										AS 'CurrentlyHomeless'
				,le.[HomelessLast5Years]									AS 'HomelessLast5Years'
				,le.[HomelessMoreThan5YearsAgo]								AS 'HomelessMoreThan5YearsAgo'
				,le.[CurrentlyInprisonOrWhenFirstSeen]						AS 'CurrentlyInprisonOrWhenFirstSeen'
				,le.[PrisonLast5Years]										AS 'PrisonLast5Years'
				,le.[PrisonAbroadLast5Years]								AS 'PrisonAbroadLast5Years'
				,le.[PrisonMoreThan5YearsAgo]								AS 'PrisonMoreThan5YearsAgo'
				,le.[PrisonAbroadMoreThan5YearsAgo]							AS 'PrisonAbroadMoreThan5YearsAgo'
				,le.[TravelledOutsideUK]									AS 'TravelledOutsideUK'
				,le.[ToHowManyCountries]									AS 'ToHowManyCountries'
				,le.[TravelCountry1]										AS 'TravelCountry1'
				,le.[DurationofTravel1(Months)]								AS 'DurationofTravel1(Months)'
				,le.[TravelCountry2]										AS 'TravelCountry2'
				,le.[DurationofTravel2(Months)]								AS 'DurationofTravel2(Months)'
				,le.[TravelCountry3]										AS 'TravelCountry3'
				,le.[DurationofTravel3(Months)]								AS 'DurationofTravel3(Months)'
				,le.[ReceivedVisitors]										AS 'ReceivedVisitors'
				,le.[FromHowManyCountries]									AS 'FromHowManyCountries'
				,le.[VisitorCountry1]										AS 'VisitorCountry1'
				,le.[DurationVisitorsStayed1]								AS 'DurationVisitorsStayed1'
				,le.[VisitorCountry2]										AS 'VisitorCountry2'
				,le.[DurationVisitorsStayed2]								AS 'DurationVisitorsStayed2'
				,le.[VisitorCountry3]										AS 'VisitorCountry3'
				,le.[DurationVisitorsStayed3]								AS 'DurationVisitorsStayed3'
				,le.[Diabetes]												AS 'Diabetes'
				,le.[HepB]													AS 'HepB'
				,le.[HepC]													AS 'HepC'
				,le.[ChronicLiverDisease]									AS 'ChronicLiverDisease'
				,le.[ChronicRenalDisease]									AS 'ChronicRenalDisease'
				,le.[ImmunoSuppression]										AS 'Immunosuppression'
				,le.[BiologicalTherapy]										AS 'BiologicalTherapy'
				,le.[Transplantation]										AS 'Transplantation'
				,le.[ImmunosuppressionOther]								AS 'ImmunosuppressionOther'
				,le.[ImmunosuppressionComments]								AS 'ImmunosuppressionComments'
				,le.[CurrentSmoker]											AS 'CurrentSmoker'
				,le.[AdultContactsIdentified]								AS 'AdultContactsIdentified'
				,le.[ChildContactsIdentified]								AS 'ChildContactsIdentified'
				,le.[TotalContactsIdentified]								AS 'TotalContactsIdentified'
				,le.[AdultContactsAssessed]									AS 'AdultContactsAssessed'
				,le.[ChildContactsAssessed]									AS 'ChildContactsAssessed'
				,le.[TotalContactsAssessed]									AS 'TotalContactsAssessed'
				,le.[AdultContactsActiveTB]									AS 'AdultContactsActiveTB'
				,le.[ChildContactsActiveTB]									AS 'ChildContactsActiveTB'
				,le.[TotalContactsActiveTB]									AS 'TotalContactsActiveTB'
				,le.[AdultContactsLTBI]										AS 'AdultContactsLTBI'
				,le.[ChildContactsLTBI]										AS 'ChildContactsLTBI'
				,le.[TotalContactsLTBI]										AS 'TotalContactsLTBI'
				,le.[AdultContactsLTBITreat]								AS 'AdultContactsLTBITreat'
				,le.[ChildContactsLTBITreat]								AS 'ChildContactsLTBITreat'
				,le.[TotalContactsLTBITreat]								AS 'TotalContactsLTBITreat'
				,le.[AdultContactsLTBITreatComplete]						AS 'AdultContactsLTBITreatComplete'
				,le.[ChildContactsLTBITreatComplete]						AS 'ChildContactsLTBITreatComplete'
				,le.[TotalContactsLTBITreatComplete]						AS 'TotalContactsLTBITreatComplete'
				,le.[TOMTreatmentInterruptedReason36mth]					AS 'TOMTreatmentInterruptedReason36mth'
				,le.[TOMTreatmentChangedReason36mth]						AS 'TOMTreatmentChangedReason36mth'
				,le.[TOMCompleteCourse36mth]								AS 'TOMCompleteCourse36mth'
				,le.[TOMIncompleteReason36mth]								AS 'TOMIncompleteReason36mth'
				,le.[TOMSubmittedDate36mth]									AS 'TOMSubmittedDate36mth'
				,le.[TOMFollowUpResult36mth]								AS 'TOMFollowUpResult36mth'
				,le.[TOMDeathDate36mth]										AS 'TOMDeathDate36mth'
				,le.[TOMDeathRelationship36mth]								AS 'TOMDeathRelationship36mth'
				,le.[TOMEndOfTreatmentDate36mth]							AS 'TOMEndOfTreatmentDate36mth'
				,le.[TOMTreatmentRegimen36mth]								AS 'TOMTreatmentRegimen36mth'
				,le.[TOMNonTuberculousMycobacteria36mth]					AS 'TOMNonTuberculousMycobacteria36mth'
				,le.[TOMConversion36mth]									AS 'TOMConversion36mth'
				,le.[TOMComment36mth]										AS 'TOMComment36mth'
				,le.[TOMReported36mth]										AS 'TOMReported36mth'
				,le.[TOMReasonExceeds24mths]								AS 'TOMReasonExceeds24mths'
				,le.[WorldRegionName]										AS 'Worldregion'

			FROM [dbo].[LegacyExtract] le
				INNER JOIN @ReusableNotification n ON n.NotificationId = le.NotificationId
			ORDER BY le.CaseReportDate DESC

			EXEC dbo.uspAddToAudit 'ETS Legacy Case Extract', @LoginGroups, @ReusableNotification
		END
	ELSE
		BEGIN
			DECLARE @ErrorText NVARCHAR(50) = 'User not authorized to view data ' + @Region
			RAISERROR (@ErrorText, 16, 1) WITH NOWAIT
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
GO