CREATE FUNCTION dbo.GetSiteDiseaseDurationStatus
	(
		@durationStatus varchar(100)
	)
	RETURNS varchar(10) 
	AS
	BEGIN
		RETURN
		CASE @durationStatus WHEN 'Yes' THEN 'Yes' ELSE '' 
	END
END


GO
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
			, PrisonLast5Years, PrisonMoreThan5YearsAgo, CurrentlyInprisonOrWhenFirstSeen
			, AlcoholUse
			, SmearSample, SmearSampleResult, SpecimenDate, ReferenceLaboratoryNumber
			, ExtractDate
			, Localpatientid, Age
			--, OwnerUserId
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
			reusableNotification.NoFixedAbode AS NoFixedAbode,
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
			reusableNotification.UkBorn AS UKBorn,
			BirthCountry,
			UkEntryYear,
			CONVERT(varchar, SymptomOnsetDate, 103) AS SymptomOnset,
			CONVERT(varchar, PresentedDate, 103) AS DatePresented,
			CONVERT(varchar, DiagnosisDate, 103) AS DateOfDiagnosis,
			CONVERT(varchar, StartOfTreatmentDate, 103) AS StartOfTreatment,

			reusableNotification.DrugMisuse AS DrugUse,
			dbo.GetSiteDiseaseDuration(DrugMisuseInLast5Years) AS DrugMisuseLast5Years,
			dbo.GetSiteDiseaseDuration(DrugMisuseMoreThan5YearsAgo) AS DrugUseMoreThan5YearsAgo,
			dbo.GetSiteDiseaseDuration(CurrentDrugMisuse) AS CurrentDrugUse,
	
			reusableNotification.Homeless,
			dbo.GetSiteDiseaseDuration(HomelessInLast5Years) AS HomelessLast5Years,
			dbo.GetSiteDiseaseDuration(HomelessMoreThan5YearsAgo) AS HomelessMoreThan5YearsAgo,
			dbo.GetSiteDiseaseDuration(CurrentlyHomeless) AS CurrentlyHomeless,

			reusableNotification.Prison,
			dbo.GetSiteDiseaseDuration(InPrisonInLast5Years) AS InPrisonInLast5Years,
			dbo.GetSiteDiseaseDuration(InPrisonMoreThan5YearsAgo) AS PrisonMoreThan5YearsAgo,
			dbo.GetSiteDiseaseDuration(CurrentlyInPrisonOrInPrisonWhenFirstSeen) AS CurrentlyInprisonOrWhenFirstSeen,

			reusableNotification.AlcoholMisuse AS AlcoholUse,

			lab.[SpecimenTypeCode] AS SmearSample,
			'Positive' AS SmearSampleResult,
			lab.SpecimenDate AS SpecimenDate,
			lab.ReferenceLaboratoryNumber,

			GETUTCDATE() As ExtractDate,
			pt.LocalPatientId,
			Age,
			--hospital.CaseManagerUsername AS OwnerUserId,
			CaseManager,
			reusableNotification.Consultant AS PatientsConsultant,
			 --ClusterNumber
			diseaseSites.Description AS DiseaseSites

		FROM ([dbo].[ReusableNotification] reusableNotification
		INNER JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch specimentMatch ON specimentMatch.NotificationID = reusableNotification.NtbsId
		INNER JOIN [dbo].LabSpecimen lab ON lab.ReferenceLaboratoryNumber = specimentMatch.ReferenceLaboratoryNumber)
		LEFT JOIN [$(NTBS)].[dbo].Patients pt ON pt.NotificationId = reusableNotification.NtbsId
		LEFT JOIN [$(NTBS)].[dbo].HospitalDetails hospital ON hospital.NotificationId = pt.NotificationId 
		LEFT JOIN [$(NTBS)].[ReferenceData].Occupation occupation ON occupation.OccupationId = pt.OccupationId
		LEFT JOIN [$(NTBS)].[ReferenceData].PHEC phec ON phec.Code = TreatmentPhecCode
		LEFT JOIN [$(NTBS)].[ReferenceData].PostcodeLookup postcode ON postcode.Postcode = REPLACE(reusableNotification.Postcode, ' ', '')
		LEFT JOIN @TempDiseaseSites diseaseSites ON diseaseSites.NotificationId = pt.NotificationId
		WHERE TreatmentPhecCode NOT IN ('PHECNI', 'PHECSCOT', 'PHECWAL') OR phec.Code IS NULL -- Exclude Wales, Scotland and Northern Ireland
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
END

DROP FUNCTION dbo.GetSiteDiseaseDurationStatus


