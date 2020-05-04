CREATE PROCEDURE [dbo].[uspPopulateForestExtract]
AS
BEGIN
	BEGIN TRY
		IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables WHERE table_name = 'ForestExtract')
			BEGIN
				DELETE FROM [dbo].ForestExtract
			END

		DECLARE @TempDiseaseSites TABLE
		(
		   NotificationId int,
		   description nvarchar(2000)
		);

		INSERT INTO @TempDiseaseSites
		SELECT NotificationId, Description = STRING_AGG(Description, N', ')
			FROM [$(NTBS)].[dbo].[NotificationSite] notificationSite
			JOIN [$(NTBS)].[ReferenceData].[Site] sites ON notificationSite.SiteId = sites.SiteId 
			GROUP BY NotificationId

		INSERT INTO ForestExtract (
			-- NotificationId,
			CaseId
			, Casereportdate, Forename, Surname, NHSNumber, DateOfBirth, AddressLine1
			, NoFixedAbode, Postcode, Sex, Hospital, ResidenceLocalAuthority
			--, ResidenceHPU
			, HPAResidenceRegion
			, Occupation, OccupationCategory, EthnicGroup
			, UKBorn, BirthCountry, UKEntryYear
			, SymptomOnset, DatePresented, DateOfDiagnosis, StartOfTreatment
			, DrugUse 
			, DrugUseLast5Years, DrugUseMoreThan5YearsAgo, CurrentDrugUse
			, Homeless 
			, HomelessLast5Years, HomelessMoreThan5YearsAgo, CurrentlyHomeless
			, Prison 
			, PrisonLast5Years, PrisonMoreThan5YearsAgo, CurrentlyInPrisonOrWhenFirstSeen
			, AlcoholUse
			, SmearSample, SmearSampleResult, SpecimenDate, ReferenceLaboratoryNumber
			, ExtractDate
			, Localpatientid, Age
			--, OwnerUserId
			, CaseManager, PatientsConsultant, DiseaseSites
			)
		SELECT
			--reusableNotification.NotificationId,
			CAST(NtbsId AS bigint)												AS CaseId,
			CONVERT(varchar(10), NotificationDate, 103)							AS CaseReportDate,
			Forename															AS Forename,
			Surname																AS Surname,
			reusableNotification.NhsNumber										As NhsNumber,
			DateOfBirth															As DateOfBirth,
			patient.Address														AS AddressLine,
			reusableNotification.NoFixedAbode									AS NoFixedAbode,
			reusableNotification.Postcode										AS Postcode,
			CASE Sex 
				WHEN 'Female' THEN 'F' 
				WHEN 'Male' THEN 'M' 
				WHEN 'Unknown' THEN 'U' 
			END																	AS Sex,
			Hospital															AS Hospital,
			LocalAuthority														AS ResidenceLocalAuthority,
			-- rn.PCT as [Hpu],
			phec.Name															AS Region,
			occupation.[Role]													AS Occupation,
			occupation.Sector													AS OccupationCategory,
			EthnicGroup															AS EthnicGroup,
			reusableNotification.UkBorn											AS UKBorn,
			BirthCountry														AS BirthCountry,
			UkEntryYear															AS UkEntryYear,
			CONVERT(varchar, SymptomOnsetDate, 103)								AS SymptomOnset,
			CONVERT(varchar, PresentedDate, 103)								AS DatePresented,
			CONVERT(varchar, DiagnosisDate, 103)								AS DateOfDiagnosis,
			CONVERT(varchar, StartOfTreatmentDate, 103)							AS StartOfTreatment,
			reusableNotification.DrugMisuse										AS DrugUse,
			dbo.ufnGetSiteDiseaseDurationStatus(DrugMisuseInLast5Years)			AS DrugMisuseLast5Years,
			dbo.ufnGetSiteDiseaseDurationStatus(DrugMisuseMoreThan5YearsAgo)	AS DrugUseMoreThan5YearsAgo,
			dbo.ufnGetSiteDiseaseDurationStatus(CurrentDrugMisuse)				AS CurrentDrugUse,
			reusableNotification.Homeless										AS Homeless,
			dbo.ufnGetSiteDiseaseDurationStatus(HomelessInLast5Years)			AS HomelessLast5Years,
			dbo.ufnGetSiteDiseaseDurationStatus(HomelessMoreThan5YearsAgo)		AS HomelessMoreThan5YearsAgo,
			dbo.ufnGetSiteDiseaseDurationStatus(CurrentlyHomeless)				AS CurrentlyHomeless,
			reusableNotification.Prison											AS Prison,
			dbo.ufnGetSiteDiseaseDurationStatus(InPrisonInLast5Years)			AS InPrisonInLast5Years,
			dbo.ufnGetSiteDiseaseDurationStatus(InPrisonMoreThan5YearsAgo)		AS PrisonMoreThan5YearsAgo,
			dbo.ufnGetSiteDiseaseDurationStatus(CurrentlyInPrisonOrInPrisonWhenFirstSeen) AS CurrentlyInPrisonOrWhenFirstSeen,
			reusableNotification.AlcoholMisuse									AS AlcoholUse,
			lab.[SpecimenTypeCode]												AS SmearSample,
			'Positive'															AS SmearSampleResult,
			lab.SpecimenDate													AS SpecimenDate,
			lab.ReferenceLaboratoryNumber										AS ReferenceLaboratoryNumber,
			GETUTCDATE()														AS ExtractDate,
			patient.LocalPatientId												AS LocalPatientId,
			Age																	AS Age,
			--hospital.CaseManagerUsername										AS OwnerUserId,
			CaseManager															AS CaseManager,
			reusableNotification.Consultant										AS PatientsConsultant,
			 --ClusterNumber													AS ClusterNumber,
			diseaseSites.Description											AS DiseaseSites
		FROM ([dbo].[ReusableNotification] reusableNotification
		INNER JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch specimenMatch ON specimenMatch.NotificationID = reusableNotification.NtbsId
		INNER JOIN [dbo].LabSpecimen lab ON lab.ReferenceLaboratoryNumber = specimenMatch.ReferenceLaboratoryNumber)
		LEFT JOIN [$(NTBS)].[dbo].Patients patient ON patient.NotificationId = reusableNotification.NtbsId
		LEFT JOIN [$(NTBS)].[dbo].HospitalDetails hospital ON hospital.NotificationId = patient.NotificationId 
		LEFT JOIN [$(NTBS)].[ReferenceData].Occupation occupation ON occupation.OccupationId = patient.OccupationId
		LEFT JOIN [$(NTBS)].[ReferenceData].PHEC phec ON phec.Code = TreatmentPhecCode
		LEFT JOIN [$(NTBS)].[ReferenceData].PostcodeLookup postcode ON postcode.Postcode = REPLACE(reusableNotification.Postcode, ' ', '')
		LEFT JOIN @TempDiseaseSites diseaseSites ON diseaseSites.NotificationId = patient.NotificationId
		WHERE TreatmentPhecCode NOT IN ('PHECNI', 'PHECSCOT', 'PHECWAL') OR phec.Code IS NULL -- Exclude Wales, Scotland and Northern Ireland

		INSERT INTO [dbo].ForestExtract 
		SELECT etsForest.*
		FROM [$(ETS)].dbo.ETSOxfordExtract etsForest
		LEFT JOIN [dbo].[ReusableNotification] reusableNotification ON reusableNotification.EtsId = etsForest.CaseId
		WHERE reusableNotification.NtbsId IS NULL
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
END

