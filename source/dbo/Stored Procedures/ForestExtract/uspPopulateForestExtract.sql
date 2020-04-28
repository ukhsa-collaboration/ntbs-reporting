CREATE PROCEDURE [dbo].[PopulateForestExtract]
AS
	

	IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables WHERE table_name = 'ForestExtract')
		BEGIN
			DELETE FROM [dbo].ForestExtract
		END

	DECLARE @TempDiseaseSites TABLE
	(
	   NotificationId int,
	   description nvarchar(250)
	);

	INSERT INTO @TempDiseaseSites
	SELECT NotificationId, Description = STRING_AGG(Description, N', ')
		FROM [$(NTBS)].[dbo].[NotificationSite] notificationSite
		JOIN [$(NTBS)].[ReferenceData].[Site] sites ON notificationSite.SiteId = sites.SiteId 
		GROUP BY NotificationId
	
	INSERT INTO ForestExtract (
			-- NotificationId,		This column is GUID in OxfordForestExtract and integer in ReusableNotification
			CaseId
			, Casereportdate, Forename, Surname, NHSNumber, DateOfBirth, AddressLine1
			, NoFixedAbode, Postcode, Sex, Hospital, ResidenceLocalAuthority
			--, ResidenceHPU
			, HPAResidenceRegion
			, Occupation, OccupationCategory, EthnicGroup
			, UKBorn, BirthCountry, UKEntryYear
			, SymptomOnset, DatePresented, DateOfDiagnosis, StartOfTreatment
			, DrugUse, DrugUseLast5Years, DrugUseMoreThan5YearsAgo, CurrentDrugUse
			, Homeless, HomelessLast5Years, HomelessMoreThan5YearsAgo, CurrentlyHomeless
			, Prison, PrisonLast5Years, PrisonMoreThan5YearsAgo, CurrentlyInprisonOrWhenFirstSeen
			, AlcoholUse
			, SmearSample, SmearSampleResult, SpecimenDate, ReferenceLaboratoryNumber
			, ExtractDate
			, Localpatientid, Age
			--, OwnerUserId			This column is GUID in OxfordForestExtract and integer in ReusableNotification
			, CaseManager, PatientsConsultant, DiseaseSites
			)
	SELECT
		--reusableNotification.NotificationId,
		CAST(NtbsId AS bigint) AS CaseId,
		CONVERT(varchar(10), NotificationDate, 103) as CaseReportDate,
		Forename,
		Surname,
		reusableNotification.NhsNumber,
		DateOfBirth,
		pt.Address AS AddressLine,
		CASE pt.NoFixedAbode
			WHEN 1 THEN 'Yes'
			ELSE ''
		END AS NoFixedAbode,
		reusableNotification.Postcode,
		CASE Sex 
			WHEN 'Female' THEN 'F' 
			WHEN 'Male' THEN 'M' 
			WHEN 'Unknown' THEN 'U' 
		END AS Sex,
		Hospital,
		LocalAuthority AS ResidenceLocalAuthority,
		-- rn.PCT as [Hpu],
		phec.Name AS Region,
		occupation.[Role] AS Occupation,
		occupation.Sector AS OccupationCategory,
		EthnicGroup,
		CASE BirthCountry 
			WHEN 'United Kigndom' THEN 'Yes' 
			WHEN NULL THEN 'Not known' 
			ELSE 'No' 
		END AS UKBorn,
		BirthCountry,
		UkEntryYear,
		CONVERT(varchar, SymptomOnsetDate, 103) AS SymptomOnset,
		CONVERT(varchar, PresentedDate, 103) AS DatePresented,
		CONVERT(varchar, DiagnosisDate, 103) AS DateOfDiagnosis,
		CONVERT(varchar, StartOfTreatmentDate, 103) AS StartOfTreatment,

		reusableNotification.DrugMisuse AS DrugUse,
		CASE DrugMisuseInLast5Years 
			WHEN 'Yes' THEN DrugMisuseInLast5Years ELSE ''
		END AS DrugMisuseLast5Years,
		CASE DrugMisuseMoreThan5YearsAgo 
			WHEN 'Yes' THEN DrugMisuseMoreThan5YearsAgo ELSE ''
		END AS DrugUseMoreThan5YearsAgo,
		CASE CurrentDrugMisuse 
			WHEN 'Yes' THEN CurrentDrugMisuse ELSE ''
		END AS CurrentDrugUse,
	
		reusableNotification.Homeless,
		CASE HomelessInLast5Years 
			WHEN 'Yes' THEN HomelessInLast5Years ELSE ''
		END AS HomelessLast5Years,
		CASE HomelessMoreThan5YearsAgo 
			WHEN 'Yes' THEN HomelessMoreThan5YearsAgo ELSE ''
		END AS HomelessMoreThan5YearsAgo,
		CASE CurrentlyHomeless
			WHEN 'Yes' THEN CurrentlyHomeless ELSE ''
		END AS CurrentlyHomeless,

		reusableNotification.Prison,
		CASE InPrisonInLast5Years 
			WHEN 'Yes' THEN InPrisonInLast5Years ELSE ''
		END AS PrisonLast5Years,
		CASE InPrisonMoreThan5YearsAgo 
			WHEN 'Yes' THEN InPrisonMoreThan5YearsAgo ELSE ''
		END AS PrisonMoreThan5YearsAgo,
		CASE CurrentlyInPrisonOrInPrisonWhenFirstSeen 
			WHEN 'Yes' THEN CurrentlyInPrisonOrInPrisonWhenFirstSeen ELSE ''
		END AS CurrentlyInprisonOrWhenFirstSeen,

		reusableNotification.AlcoholMisuse AS AlcoholUse,

		lab.[SpecimenTypeCode] AS SmearSample,
		'Positive' AS SmearSampleResult,
		lab.SpecimenDate AS SpecimenDate,
		lab.ReferenceLaboratoryNumber,

		GETDATE() As ExtractDate,
		pt.LocalPatientId,
		Age,
		--hospital.CaseManagerUsername AS OwnerUserId,
		CaseManager,
		reusableNotification.Consultant AS PatientsConsultant,
		 --ClusterNumber
		diseaseSites.Description AS DiseaseSites

	FROM ([dbo].[ReusableNotification] reusableNotification
	INNER JOIN [dbo].LabSpecimen lab ON lab.PatientNhsNumber = reusableNotification.NhsNumber AND SourceSystem = 'NTBS')
	LEFT JOIN [$(NTBS)].[dbo].Patients pt ON CAST(pt.NotificationId AS varchar(50)) = reusableNotification.NotificationId
	LEFT JOIN [$(NTBS)].[dbo].HospitalDetails hospital ON hospital.NotificationId = pt.NotificationId 
	LEFT JOIN [$(NTBS)].[ReferenceData].Occupation occupation ON occupation.OccupationId = pt.OccupationId
	LEFT JOIN [$(NTBS)].[ReferenceData].PHEC phec ON phec.Code = TreatmentPhecCode
	LEFT JOIN [$(NTBS)].[ReferenceData].PostcodeLookup postcode ON postcode.Postcode = REPLACE(reusableNotification.Postcode, ' ', '')
	LEFT JOIN @TempDiseaseSites diseaseSites ON diseaseSites.NotificationId = pt.NotificationId
	WHERE TreatmentPhecCode NOT IN ('PHECNI', 'PHECSCOT', 'PHECWAL') OR phec.Code IS NULL -- Exclude Wales, Scotland and Northern Ireland