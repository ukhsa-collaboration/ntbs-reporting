CREATE PROCEDURE [dbo].[uspPopulateForestExtract]
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
		
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables WHERE table_name = 'ForestExtract')
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
			-- NotificationId,
			CaseId
			,Casereportdate
			,Forename
			,Surname
			,NHSNumber
			,DateOfBirth
			,AddressLine1
			,NoFixedAbode
			,Postcode
			,Sex
			,Hospital
			,ResidenceLocalAuthority
			,ResidenceHPU
			,HPAResidenceRegion
			,Occupation
			,OccupationCategory
			,EthnicGroup
			,UKBorn
			,BirthCountry
			,UKEntryYear
			,SymptomOnset
			,DatePresented
			,DateOfDiagnosis
			,StartOfTreatment
			,DrugUse 
			,DrugUseLast5Years, DrugUseMoreThan5YearsAgo, CurrentDrugUse
			,Homeless 
			,HomelessLast5Years, HomelessMoreThan5YearsAgo, CurrentlyHomeless
			,Prison 
			,PrisonLast5Years, PrisonMoreThan5YearsAgo, CurrentlyInPrisonorWhenFirstSeen
			,TreatmentRegion
			,AlcoholUse
			,SmearSample
			,SmearSampleResult
			,SpecimenDate
			,ReferenceLaboratoryNumber
			,ExtractDate
			,Localpatientid
			,Age
			,CaseManager 
			,PatientsConsultant
			,DiseaseSites
			)
		SELECT
			--reusableNotification.NotificationId,
			CAST(n.NotificationId AS bigint)																AS CaseId,
			CONVERT(varchar(10), n.NotificationDate, 103)													AS CaseReportDate,
			patient.GivenName																				AS Forename,
			patient.FamilyName																				AS Surname,
			patient.NhsNumber																				AS NhsNumber,
			patient.Dob																						AS DateOfBirth,
			patient.[Address]																				AS AddressLine,
			patient.NoFixedAbode																			AS NoFixedAbode,
			patient.Postcode																				AS Postcode,
			CASE patient.SexId 
				WHEN 1 THEN 'M' 
				WHEN 2 THEN 'F' 
				WHEN 3 THEN 'U' 
			END																								AS Sex,
			hospital.Name																					AS Hospital,
			localAuth.Name																					AS ResidenceLocalAuthority,
			nacs.HPU																						AS ResidenceHPU,
			patientPhec.Name																				AS Region,
			occupation.[Role]																				AS Occupation,
			occupation.Sector																				AS OccupationCategory,
			ethnicity.Label																					AS EthnicGroup,
			patient.UkBorn																					AS UKBorn,
			UPPER(country.Name)																				AS BirthCountry,
			patient.YearOfUkEntry																			AS UkEntryYear,
			CONVERT(varchar, clinicalDetails.SymptomStartDate, 103)											AS SymptomOnset,
			CONVERT(varchar, clinicalDetails.FirstPresentationDate, 103)									AS DatePresented,
			CONVERT(varchar, clinicalDetails.DiagnosisDate, 103)											AS DateOfDiagnosis,
			CONVERT(varchar, clinicalDetails.TreatmentStartDate, 103)										AS StartOfTreatment,
			drugs.Status																					AS DrugUse,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(drugs.InPastFiveYears)					AS DrugMisuseLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(drugs.MoreThanFiveYearsAgo)				AS DrugUseMoreThan5YearsAgo,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(drugs.IsCurrent)							AS CurrentDrugUse,
			homeless.Status																					AS Homeless,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(homeless.InPastFiveYears)					AS HomelessLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(homeless.MoreThanFiveYearsAgo)			AS HomelessMoreThan5YearsAgo,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(homeless.IsCurrent)						AS CurrentlyHomeless,
			prison.Status																					AS Prison,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(prison.InPastFiveYears)					AS InPrisonInLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(prison.MoreThanFiveYearsAgo)				AS PrisonMoreThan5YearsAgo,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(prison.IsCurrent)							AS CurrentlyInPrisonOrWhenFirstSeen,
			servicePhec.Name																				AS TreatmentRegion,
			socialRiskFactors.AlcoholMisuseStatus															AS AlcoholUse,
			lab.[SpecimenTypeCode]																			AS SmearSample,
			'Positive'																						AS SmearSampleResult,
			lab.SpecimenDate																				AS SpecimenDate,
			lab.ReferenceLaboratoryNumber																	AS ReferenceLaboratoryNumber,
			GETUTCDATE()																					AS ExtractDate,
			patient.LocalPatientId																			AS LocalPatientId,
			CAST(dbo.ufnGetAgefrom(patient.Dob,n.NotificationDate) AS tinyint)								AS Age,
			u.Username																						AS CaseManager,
			hospitalDetails.Consultant																		AS PatientsConsultant,
			 --ClusterNumber																				AS ClusterNumber,
			diseaseSites.[Description]																		AS DiseaseSites
		FROM ([$(NTBS)].[dbo].Notification n
		INNER JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.NotificationID = n.NotificationId
		INNER JOIN [dbo].LabSpecimen lab ON lab.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber)
		LEFT JOIN [$(NTBS)].[dbo].Patients patient ON patient.NotificationId = n.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].HospitalDetails hospitalDetails ON hospitalDetails.NotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].ClinicalDetails clinicalDetails ON clinicalDetails.NotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].RiskFactorDrugs drugs ON drugs.SocialRiskFactorsNotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].RiskFactorHomelessness homeless ON homeless.SocialRiskFactorsNotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].RiskFactorImprisonment prison ON prison.SocialRiskFactorsNotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].SocialRiskFactors socialRiskFactors ON socialRiskFactors.NotificationId = patient.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].[User] u ON u.Id = hospitalDetails.CaseManagerId
		LEFT JOIN [$(NTBS)].[ReferenceData].TbService tbService ON tbService.Code = hospitalDetails.TBServiceCode
		LEFT JOIN [$(NTBS)].[ReferenceData].PostcodeLookup postcodeLookup ON postcodeLookup.Postcode = patient.PostcodeToLookup
		LEFT JOIN [$(NTBS)].[ReferenceData].LocalAuthority localAuth ON localAuth.Code = postcodeLookup.LocalAuthorityCode
		LEFT JOIN [$(NTBS)].[ReferenceData].LocalAuthorityToPHEC localPhecMap ON localAuth.Code = localPhecMap.LocalAuthorityCode
		LEFT JOIN [$(NTBS)].[ReferenceData].PHEC patientPhec ON localPhecMap.LocalAuthorityCode = patientPhec.Code
		LEFT JOIN [$(NTBS)].[ReferenceData].PHEC servicePhec ON servicePhec.Code = tbService.PHECCode
		LEFT JOIN [$(NTBS)].[ReferenceData].Occupation occupation ON occupation.OccupationId = patient.OccupationId
		LEFT JOIN [$(NTBS)].[ReferenceData].Hospital hospital ON hospitalDetails.HospitalId = hospital.HospitalId
		LEFT JOIN [$(NTBS)].[ReferenceData].Ethnicity ethnicity ON ethnicity.EthnicityId = patient.EthnicityId
		LEFT JOIN [$(NTBS)].[ReferenceData].Country country ON country.CountryId = patient.CountryId
		LEFT JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] pl ON pl.Pcode = REPLACE(patient.Postcode, ' ', '')
		LEFT JOIN [$(ETS)].[dbo].[NACS_pctlookup] nacs ON nacs.PCT_code = pl.PctCode
		LEFT JOIN @TempDiseaseSites diseaseSites ON diseaseSites.NotificationId = patient.NotificationId
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

		--convert Yorkshire and Humber to Yorkshire and The Humber
		UPDATE dbo.ForestExtract
			SET HPAResidenceRegion = 'Yorkshire and The Humber'
			WHERE HPAResidenceRegion = 'Yorkshire and Humber'


		DECLARE @IncludeETS BIT = (SELECT TOP(1) IncludeETS FROM [dbo].[ReportingFeatureFlags])
		IF @IncludeETS = 1
		BEGIN
			INSERT INTO [dbo].ForestExtract 
			SELECT etsForest.*
			FROM [$(ETS)].dbo.ETSOxfordExtract etsForest
			LEFT JOIN [dbo].[ReusableNotification] reusableNotification ON reusableNotification.EtsId = etsForest.CaseId
			WHERE reusableNotification.NtbsId IS NULL
		END
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		EXEC dbo.uspHandleException
	END CATCH
END

