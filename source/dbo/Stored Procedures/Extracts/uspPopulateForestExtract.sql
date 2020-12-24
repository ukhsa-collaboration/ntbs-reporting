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
			,PrisonLast5Years, PrisonMoreThan5YearsAgo, CurrentlyInPrisonOrWhenFirstSeen
			,TreatmentRegion
			,AlcoholUse
			,SmearSample
			,SmearSampleResult
			,SpecimenDate
			,ReferenceLaboratoryNumber
			,ExtractDate
			,Localpatientid
			,Age
			--,OwnerUserId
			,CaseManager 
			,PatientsConsultant
			,DiseaseSites
			)
		SELECT
			--reusableNotification.NotificationId,
			CAST(NtbsId AS bigint)																			AS CaseId,
			CONVERT(varchar(10), NotificationDate, 103)														AS CaseReportDate,
			Forename																						AS Forename,
			Surname																							AS Surname,
			rn.NhsNumber																					AS NhsNumber,
			DateOfBirth																						AS DateOfBirth,
			patient.[Address]																				AS AddressLine,
			rn.NoFixedAbode																					AS NoFixedAbode,
			rn.Postcode																						AS Postcode,
			CASE Sex 
				WHEN 'Female' THEN 'F' 
				WHEN 'Male' THEN 'M' 
				WHEN 'Unknown' THEN 'U' 
			END																								AS Sex,
			Hospital																						AS Hospital,
			LocalAuthority																					AS ResidenceLocalAuthority,
			nacs.HPU																						AS ResidenceHPU,
			rn.ResidencePhec																				AS Region,
			occupation.[Role]																				AS Occupation,
			occupation.Sector																				AS OccupationCategory,
			EthnicGroup																						AS EthnicGroup,
			rn.UkBorn																						AS UKBorn,
			UPPER(BirthCountry)																				AS BirthCountry,
			UkEntryYear																						AS UkEntryYear,
			CONVERT(varchar, SymptomOnsetDate, 103)															AS SymptomOnset,
			CONVERT(varchar, PresentedDate, 103)															AS DatePresented,
			CONVERT(varchar, DiagnosisDate, 103)															AS DateOfDiagnosis,
			CONVERT(varchar, StartOfTreatmentDate, 103)														AS StartOfTreatment,
			rn.DrugMisuse																					AS DrugUse,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(DrugMisuseInLast5Years)					AS DrugMisuseLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(DrugMisuseMoreThan5YearsAgo)				AS DrugUseMoreThan5YearsAgo,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(CurrentDrugMisuse)						AS CurrentDrugUse,
			rn.Homeless																						AS Homeless,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(HomelessInLast5Years)						AS HomelessLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(HomelessMoreThan5YearsAgo)				AS HomelessMoreThan5YearsAgo,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(CurrentlyHomeless)						AS CurrentlyHomeless,
			rn.Prison																						AS Prison,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(InPrisonInLast5Years)						AS InPrisonInLast5Years,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(InPrisonMoreThan5YearsAgo)				AS PrisonMoreThan5YearsAgo,
			dbo.ufnGetFormattedSiteDiseaseDurationStatusForForest(CurrentlyInPrisonOrInPrisonWhenFirstSeen) AS CurrentlyInPrisonOrWhenFirstSeen,
			rn.TreatmentPhec																				AS TreatmentRegion,
			rn.AlcoholMisuse																				AS AlcoholUse,
			lab.[SpecimenTypeCode]																			AS SmearSample,
			'Positive'																						AS SmearSampleResult,
			lab.SpecimenDate																				AS SpecimenDate,
			lab.ReferenceLaboratoryNumber																	AS ReferenceLaboratoryNumber,
			GETUTCDATE()																					AS ExtractDate,
			patient.LocalPatientId																			AS LocalPatientId,
			Age																								AS Age,
			--hospital.CaseManagerUsername																	AS OwnerUserId,
			CaseManager																						AS CaseManager,
			rn.Consultant																					AS PatientsConsultant,
			 --ClusterNumber																				AS ClusterNumber,
			diseaseSites.[Description]																		AS DiseaseSites
		FROM ([dbo].[ReusableNotification] rn
		INNER JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.NotificationID = rn.NtbsId
		INNER JOIN [dbo].LabSpecimen lab ON lab.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber)
		LEFT JOIN [$(NTBS)].[dbo].Patients patient ON patient.NotificationId = rn.NtbsId
		LEFT JOIN [$(NTBS)].[dbo].HospitalDetails hospital ON hospital.NotificationId = patient.NotificationId 
		LEFT JOIN [$(NTBS)].[ReferenceData].Occupation occupation ON occupation.OccupationId = patient.OccupationId
		LEFT JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] pl ON pl.Pcode = REPLACE(rn.Postcode, ' ', '')
		LEFT JOIN [$(ETS)].[dbo].[NACS_pctlookup] nacs ON nacs.PCT_code = pl.PctCode
		LEFT JOIN @TempDiseaseSites diseaseSites ON diseaseSites.NotificationId = patient.NotificationId
		WHERE nsm.MatchType = 'Confirmed' 
			AND (rn.TreatmentPhec IN ('North East', 'North West', 'Yorkshire and Humber', 'West Midlands', 
										'East Midlands', 'East of England', 'London', 'South East', 'South West'));

		WITH VNTR AS
		(SELECT DISTINCT
			nsm.ReferenceLaboratoryNumber, v.VntrProfile
		FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch] nsm
			INNER JOIN [$(Labbase2)].[dbo].[Anonymised] a ON a.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber
			INNER JOIN [$(Labbase2)].[dbo].[VntrProfile] v ON v.LabDataId = a.LabDataID
		WHERE nsm.MatchType = 'Confirmed')

		--set VNTR
		UPDATE dbo.ForestExtract
			SET VntrProfile = v.VntrProfile
			FROM dbo.ForestExtract e
				INNER JOIN VNTR v ON v.ReferenceLaboratoryNumber = e.ReferenceLaboratoryNumber

		--convert Yorkshire and Humber to Yorkshire and The Humber
		UPDATE dbo.ForestExtract
			SET HPAResidenceRegion = 'Yorkshire and The Humber'
			WHERE HPAResidenceRegion = 'Yorkshire and Humber'

		INSERT INTO [dbo].ForestExtract 
		SELECT etsForest.*
		FROM [$(ETS)].dbo.ETSOxfordExtract etsForest
		LEFT JOIN [dbo].[ReusableNotification] reusableNotification ON reusableNotification.EtsId = etsForest.CaseId
		WHERE reusableNotification.NtbsId IS NULL

		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		EXEC dbo.uspHandleException
	END CATCH
END

