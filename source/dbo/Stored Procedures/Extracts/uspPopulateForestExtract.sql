CREATE PROCEDURE [dbo].[uspPopulateForestExtract]
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION

		IF EXISTS (SELECT * FROM [INFORMATION_SCHEMA].[TABLES] WHERE TABLE_NAME = 'ForestExtract')
			BEGIN
				TRUNCATE TABLE [dbo].ForestExtract
			END

		DECLARE @TempDiseaseSites TABLE
		(
		   NotificationId int,
		   [Description] nvarchar(2000)
		);

		INSERT INTO @TempDiseaseSites
		SELECT NotificationId, [Description] = STRING_AGG([Description], N',')
			FROM [$(NTBS)].[dbo].[NotificationSite] notificationSite
			JOIN [$(NTBS)].[ReferenceData].[Site] sites ON notificationSite.SiteId = sites.SiteId
			GROUP BY NotificationId

		INSERT INTO ForestExtract (
			CaseId
			,EtsId
			,LtbrId
			,Casereportdate
			,Forename
			,Surname
			,NHSNumber
			,DateOfBirth
			,[Address]
			,NoFixedAbode
			,Postcode
			,Sex
			,Hospital
			,HospitalTBService
			,ResidenceLocalAuthority
			,ResidenceHPU
			,Occupation
			,OccupationCategory
			,EthnicGroup
			,UKBorn
			,BirthCountry
			,UKEntryYear
			,Symptomatic
			,SymptomOnset
			,FirstPresentationDate
			,HealthcareSetting
			,TBServicePresentationDate
			,DateOfDiagnosis
			,StartOfTreatment
			,ChestXRayResult
			,DrugUse
			,CurrentDrugUse, DrugUseLast5Years, DrugUseMoreThan5YearsAgo
			,Homeless
			,CurrentlyHomeless, HomelessLast5Years, HomelessMoreThan5YearsAgo
			,Prison
			,CurrentlyInPrisonOrWhenFirstSeen, PrisonLast5Years, PrisonMoreThan5YearsAgo
			,Smoking
			,CurrentSmoking, SmokingLast5Years, SmokingMoreThan5YearsAgo
			,AlcoholUse
			,MentalHealth
			,AsylumSeeker
			,ImmigrationDetainee
			,TreatmentRegion
			,SmearSample
			,SmearSampleResult
			,SpecimenDate
			,ReferenceLaboratoryNumber
			,ExtractDate
			,Localpatientid
			,Age
			,OwnerUsername
			,CaseManager
			,PatientsConsultant
			,DiseaseSites
			)
		SELECT
			CAST(n.NotificationId AS bigint)																AS CaseId,
			n.ETSID																							AS EtsId,
			n.LTBRID																						AS LtbrId,
			n.NotificationDate																				AS CaseReportDate,
			patient.GivenName																				AS Forename,
			patient.FamilyName																				AS Surname,
			patient.NhsNumber																				AS NhsNumber,
			patient.Dob																						AS DateOfBirth,
			patient.[Address]																				AS [Address],
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(patient.NoFixedAbode)						AS NoFixedAbode,
			patient.Postcode																				AS Postcode,
			CASE patient.SexId
				WHEN 1 THEN 'M'
				WHEN 2 THEN 'F'
				WHEN 3 THEN 'U'
			END																								AS Sex,
			hospital.Name																					AS Hospital,
			tbService.Name																					AS HospitalTBService,
			localAuth.Name																					AS ResidenceLocalAuthority,
			nacs.HPU																						AS ResidenceHPU,
			occupation.[Role]																				AS Occupation,
			occupation.Sector																				AS OccupationCategory,
			ethnicity.Label																					AS EthnicGroup,
			dbo.ufnUkBorn(patient.CountryId)																AS UKBorn,
			UPPER(country.Name)																				AS BirthCountry,
			patient.YearOfUkEntry																			AS UkEntryYear,
			dbo.ufnYesNo(clinicalDetails.IsSymptomatic)														AS Symptomatic,
			clinicalDetails.SymptomStartDate																AS SymptomOnset,
			clinicalDetails.FirstPresentationDate															AS FirstPresentationDate,
			clinicalDetails.HealthcareSetting																AS HealthcareSetting,
			clinicalDetails.TBServicePresentationDate														AS TBServicePresentationDate,
			clinicalDetails.DiagnosisDate																	AS DateOfDiagnosis,
			clinicalDetails.TreatmentStartDate																AS StartOfTreatment,
			COALESCE(ChestXRayResult, 'No result')															AS ChestXRayResult,
			drugs.Status																					AS DrugUse,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(drugs.IsCurrent)							AS CurrentDrugUse,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(drugs.InPastFiveYears)					AS DrugMisuseLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(drugs.MoreThanFiveYearsAgo)				AS DrugUseMoreThan5YearsAgo,
			homeless.Status																					AS Homeless,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(homeless.IsCurrent)						AS CurrentlyHomeless,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(homeless.InPastFiveYears)					AS HomelessLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(homeless.MoreThanFiveYearsAgo)			AS HomelessMoreThan5YearsAgo,
			prison.Status																					AS Prison,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(prison.IsCurrent)							AS CurrentlyInPrisonOrWhenFirstSeen,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(prison.InPastFiveYears)					AS InPrisonInLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(prison.MoreThanFiveYearsAgo)				AS PrisonMoreThan5YearsAgo,
			smoking.Status																					AS Smoking,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(smoking.IsCurrent)						AS CurrentSmoking,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(smoking.InPastFiveYears)					AS SmokingLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(smoking.MoreThanFiveYearsAgo)				AS SmokingMoreThan5YearsAgo,
			socialRiskFactors.AlcoholMisuseStatus															AS AlcoholUse,
			socialRiskFactors.MentalHealthStatus															AS MentalHealth,
			socialRiskFactors.AsylumSeekerStatus															AS AsylumSeeker,
			socialRiskFactors.ImmigrationDetaineeStatus														AS ImmigrationDetainee,
			servicePhec.Name																				AS TreatmentRegion,
			lab.[SpecimenTypeCode]																			AS SmearSample,
			'Positive'																						AS SmearSampleResult,
			lab.SpecimenDate																				AS SpecimenDate,
			lab.ReferenceLaboratoryNumber																	AS ReferenceLaboratoryNumber,
			GETUTCDATE()																					AS ExtractDate,
			patient.LocalPatientId																			AS LocalPatientId,
			CAST(dbo.ufnGetAgefrom(patient.Dob,n.NotificationDate) AS tinyint)								AS Age,
			u.Username																						AS OwnerUsername,
			u.DisplayName																					AS CaseManager,
			hospitalDetails.Consultant																		AS PatientsConsultant,
			diseaseSites.[Description]																		AS DiseaseSites
		FROM ([$(NTBS)].[dbo].Notification n
		INNER JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.NotificationID = n.NotificationId
		INNER JOIN [$(NTBS_Specimen_Matching)].[dbo].LabSpecimen lab ON lab.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber)
		LEFT JOIN [$(NTBS)].[dbo].Patients patient ON patient.NotificationId = n.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].HospitalDetails hospitalDetails ON hospitalDetails.NotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].ClinicalDetails clinicalDetails ON clinicalDetails.NotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].RiskFactorDrugs drugs ON drugs.SocialRiskFactorsNotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].RiskFactorHomelessness homeless ON homeless.SocialRiskFactorsNotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].RiskFactorImprisonment prison ON prison.SocialRiskFactorsNotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].RiskFactorSmoking smoking ON smoking.SocialRiskFactorsNotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].SocialRiskFactors socialRiskFactors ON socialRiskFactors.NotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].[User] u ON u.Id = hospitalDetails.CaseManagerId
		LEFT JOIN [$(NTBS)].[ReferenceData].TbService tbService ON tbService.Code = hospitalDetails.TBServiceCode
		LEFT JOIN [$(NTBS)].[ReferenceData].PostcodeLookup postcodeLookup ON postcodeLookup.Postcode = patient.PostcodeToLookup
		LEFT JOIN [$(NTBS)].[ReferenceData].LocalAuthority localAuth ON localAuth.Code = postcodeLookup.LocalAuthorityCode
		LEFT JOIN [$(NTBS)].[ReferenceData].LocalAuthorityToPHEC localPhecMap ON localAuth.Code = localPhecMap.LocalAuthorityCode
		LEFT JOIN [$(NTBS)].[ReferenceData].PHEC servicePhec ON servicePhec.Code = tbService.PHECCode
		LEFT JOIN [$(NTBS)].[ReferenceData].Occupation occupation ON occupation.OccupationId = patient.OccupationId
		LEFT JOIN [$(NTBS)].[ReferenceData].Hospital hospital ON hospitalDetails.HospitalId = hospital.HospitalId
		LEFT JOIN [$(NTBS)].[ReferenceData].Ethnicity ethnicity ON ethnicity.EthnicityId = patient.EthnicityId
		LEFT JOIN [$(NTBS)].[ReferenceData].Country country ON country.CountryId = patient.CountryId
		LEFT JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] pl ON pl.Pcode = patient.PostcodeToLookup
		LEFT JOIN [$(ETS)].[dbo].[NACS_pctlookup] nacs ON nacs.PCT_code = pl.PctCode
		LEFT JOIN @TempDiseaseSites diseaseSites ON diseaseSites.NotificationId = patient.NotificationId
		OUTER APPLY [dbo].[ufnGetCaseRecordChestXrayResults](n.NotificationId, clinicalDetails.DiagnosisDate) ChestXRayResult
		WHERE nsm.MatchType = 'Confirmed'
			AND (servicePhec.Name IN ('North East', 'North West', 'Yorkshire and Humber', 'West Midlands',
										'East Midlands', 'East of England', 'London', 'South East', 'South West'));


		--VNTR and ClusterNumber are now fixed values, but are expressed at the level of OpieId, which we are not currently supporting
		--in the equivalent extract
		--see if there is a value populated on any record for the Case Id and Reference Laboratory Number and populate the columns with this

		WITH LegacyVntrCluster AS
		(SELECT DISTINCT CaseId, ReferenceLaboratoryNumber, VntrProfile, ClusterNumber
		 FROM [$(ETS)].[dbo].[ETSOxfordExtract]
		 WHERE VntrProfile IS NOT NULL AND ReferenceLaboratoryNumber IS NOT NULL)

		--set VNTR and Cluster
		UPDATE dbo.ForestExtract
			SET VntrProfile = v.VntrProfile,
			ClusterNumber = v.ClusterNumber
			FROM dbo.ForestExtract e
				INNER JOIN LegacyVntrCluster v ON v.ReferenceLaboratoryNumber = e.ReferenceLaboratoryNumber

		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		EXEC dbo.uspHandleException
	END CATCH
END

