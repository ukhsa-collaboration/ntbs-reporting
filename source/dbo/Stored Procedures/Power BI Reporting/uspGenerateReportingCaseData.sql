CREATE PROCEDURE [dbo].[uspGenerateReportingCaseData]
	
AS
BEGIN TRY	

	EXEC [dbo].[uspGenerateNtbsCaseRecord]
	
	EXEC [dbo].[uspGenerateEtsCaseRecord]
	


	--finally do stuff that makes sense just to do for all records, like the last recorded treatment outcome 

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
		,Lat = rp.lat
		,Long = rp.long
		,LocalAuthorityCode = rp.LA_Code
		,LocalAuthority = la.LA_Name
		,ResidencePhec = reside.PHEC_Name
		,TreatmentPhec = treat.PHEC_Name
		,TbService = tbs.TB_Service_Name
		,LastRecordedTreatmentOutcome =
			CASE
				WHEN TreatmentOutcome36months IS NOT NULL AND TreatmentOutcome36months != '' AND TreatmentOutcome36months != 'Error: invalid value' THEN TreatmentOutcome36months
				WHEN TreatmentOutcome24months IS NOT NULL AND TreatmentOutcome24months != '' AND TreatmentOutcome24months != 'Error: invalid value' THEN TreatmentOutcome24months
				WHEN TreatmentOutcome12months IS NOT NULL AND TreatmentOutcome12months != '' AND TreatmentOutcome12months != 'Error: invalid value' THEN TreatmentOutcome12months
			END
	FROM [dbo].[Record_CaseData] cd
		INNER JOIN [dbo].[Record_PersonalDetails] pd ON pd.NotificationId = cd.NotificationId
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] rp ON rp.Pcode = pd.PostcodeToLookup
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Local_Authority] la ON la.LA_Code = rp.LA_Code
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] reside ON reside.PHEC_Code = rr.ResidencePhecCode
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC] treat ON treat.PHEC_Code = rr.TreatmentPhecCode
		LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs ON tbs.TB_Service_Code = rr.TBServiceCode

			

END TRY
BEGIN CATCH
	THROW
END CATCH