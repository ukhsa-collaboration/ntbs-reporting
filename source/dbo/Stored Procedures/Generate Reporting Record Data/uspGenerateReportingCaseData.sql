CREATE PROCEDURE [dbo].[uspGenerateReportingCaseData]
AS
BEGIN TRY	

	EXEC [dbo].[uspGenerateNtbsCaseRecord]
	
	EXEC [dbo].[uspGenerateEtsCaseRecord]
	
	--finally do stuff that makes sense just to do for all records, like the last recorded treatment outcome 

	EXEC [dbo].[uspGenerateTestResultSummaries]

	UPDATE cd 
	SET AnySocialRiskFactor = CASE 
		WHEN AlcoholMisuse = 'Yes' 
			OR DrugMisuse = 'Yes' 
			OR Homeless = 'Yes' 
			OR Prison = 'Yes'
			OR MentalHealth = 'Yes'
			OR AsylumSeeker = 'Yes'
			OR ImmigrationDetainee = 'Yes'
		THEN 'Yes' ELSE 'No' END
		,ResolvedResidenceHPU = nacs.HPU
		,Lat = rp.lat
		,Long = rp.long
		,LSOACode = rph.LSOACode
		,LSOAName = rph.LSOAName
		,LocalAuthority = la.LA_Name
		,ResidencePhec = reside.PHEC_Name
		,TreatmentPhec = treat.PHEC_Name
		,AssignedRegion = Coalesce(reside.PHEC_Name,treat.PHEC_Name)
		,TreatmentICB = rph.ICBName
		,AssignedICB = Coalesce(rp.ICBName,rph.ICBName)
		,TbService = tbs.TB_Service_Name
		,Hospital = h.HospitalName
		,LastRecordedTreatmentOutcome =
			CASE
				WHEN TreatmentOutcome36months IS NOT NULL AND TreatmentOutcome36months != '' AND TreatmentOutcome36months != 'Error: invalid value' THEN TreatmentOutcome36months
				WHEN TreatmentOutcome24months IS NOT NULL AND TreatmentOutcome24months != '' AND TreatmentOutcome24months != 'Error: invalid value' THEN TreatmentOutcome24months
				WHEN TreatmentOutcome12months IS NOT NULL AND TreatmentOutcome12months != '' AND TreatmentOutcome12months != 'Error: invalid value' THEN TreatmentOutcome12months
			END
		,LastRecordedTreatmentOutcomeDescriptive = COALESCE(TreatmentOutcome36monthsDescriptive, TreatmentOutcome24monthsDescriptive, TreatmentOutcome12monthsDescriptive)
		,ChestXRayResult = COALESCE(ChestXRayResult, 'No result')
		,ChestCTResult = COALESCE(ChestCTResult, 'No result')
	FROM [dbo].[Record_CaseData] cd
		INNER JOIN [dbo].[Record_PersonalDetails] pd ON pd.NotificationId = cd.NotificationId
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] rp ON rp.Pcode = pd.PostcodeToLookup
		LEFT OUTER JOIN [$(ETS)].[dbo].[NACS_pctlookup] nacs ON nacs.PCT_code = rp.PctCode
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Local_Authority] la ON la.LA_Code = rp.LA_Code
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] reside ON reside.PHEC_Code = rr.ResidencePhecCode
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] treat ON treat.PHEC_Code = rr.TreatmentPhecCode
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs ON tbs.TB_Service_Code = rr.TBServiceCode
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h ON h.HospitalId = cd.HospitalId
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] rph ON rph.Pcode = h.Postcode
		--LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PostcodeLookup] pl ON pl.postcode = COALESCE(pd.PostcodeToLookup,h.Postcode)

	UPDATE pd
	SET Initials = LEFT(pd.GivenName,1) + LEFT(pd.FamilyName,1)
	FROM [dbo].Record_PersonalDetails pd

	--now add the list of linked notifications
	EXEC [dbo].[uspGenerateLinkedNotifications]
END TRY
BEGIN CATCH
	THROW
END CATCH
