CREATE PROCEDURE [dbo].[uspGenerateReportingCaseData]
AS
BEGIN TRY	

	EXEC [dbo].[uspGenerateNtbsCaseRecord]
	
	EXEC [dbo].[uspGenerateEtsCaseRecord]
	
	--finally do stuff that makes sense just to do for all records, like the last recorded treatment outcome 

	EXEC [dbo].[uspGenerateSputumResult]

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
		,LocalAuthority = la.LA_Name
		,ResidencePhec = reside.PHEC_Name
		,TreatmentPhec = treat.PHEC_Name
		,TbService = tbs.TB_Service_Name
		,Hospital = h.HospitalName
		,LastRecordedTreatmentOutcome =
			CASE
				WHEN TreatmentOutcome36months IS NOT NULL AND TreatmentOutcome36months != '' AND TreatmentOutcome36months != 'Error: invalid value' THEN TreatmentOutcome36months
				WHEN TreatmentOutcome24months IS NOT NULL AND TreatmentOutcome24months != '' AND TreatmentOutcome24months != 'Error: invalid value' THEN TreatmentOutcome24months
				WHEN TreatmentOutcome12months IS NOT NULL AND TreatmentOutcome12months != '' AND TreatmentOutcome12months != 'Error: invalid value' THEN TreatmentOutcome12months
			END
		,ChestXRayResult = COALESCE(ChestXRayResult, 'No result')
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

	--now add the list of linked notifications
	EXEC [dbo].[uspGenerateLinkedNotifications]
END TRY
BEGIN CATCH
	THROW
END CATCH