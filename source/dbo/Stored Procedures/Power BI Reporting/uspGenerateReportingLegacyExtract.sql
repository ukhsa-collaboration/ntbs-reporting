/*

	This populates the additional fields which are only required for the legacy case extract
	For ETS records, these are not calculated in the reporting service as they are already calculated in ETS

*/

CREATE PROCEDURE [dbo].[uspGenerateReportingLegacyExtract]
AS
BEGIN TRY
	INSERT INTO [dbo].[Record_LegacyExtract]([NotificationId]
		,[LocalPatientId]
        ,[ReportYear]
        ,[DenotificationDate]
        ,[DenotificationComments]
        ,[Title]
        ,[AddressLine1]
        ,[AddressLine2]
        ,[Town]
        ,[County]
        ,[BcgVaccinationDate]
        ,[InPatient]
        ,[Comments]
        ,[ImmunosuppressionComments]
        ,[PrisonAbroadLast5Years]
        ,[PrisonAbroadMoreThan5YearsAgo]
		,[PCT]
        ,[HPU]
        ,[TreatmentHPU]
        ,[HospitalPCT]
        ,[HospitalLocalAuthority]
        ,[ResolvedResidenceHPU] --this has the same value as HPU
        ,[ResolvedResidenceRegion]
        ,[ResolvedResidenceLA]
        ,[WorldRegionName])

		SELECT
			rr.NotificationId															AS NotificationId
			,p.LocalPatientId															AS LocalPatientId
			,DATEPART(YEAR, rr.NotificationDate)		                                AS ReportYear
			,CONVERT(DATE, dn.DateOfDenotification)                                     AS DenotificationDate
			,drm.ReasonOutputName				                                        AS DenotificationComments
			,NULL																		AS Title --field does not exist in NTBS
			,REPLACE(p.[Address], char(10), ' ')										AS AddressLine1
			,NULL																		AS AddressLine2 --no separate address lines in NTBS
			,NULL																		AS Town --ditto
			,NULL																		AS County --ditto
			,CONVERT(NVARCHAR(5), clinical.BCGVaccinationYear)							AS BCGVaccinationDate
			,'Not known'																AS InPatient --field does not exist in NTBS
			,LEFT(clinical.Notes, 500)													AS Comments
            ,COALESCE(LEFT(id.OtherDescription, 50), '')                                AS ImmunosuppressionComments
			,NULL																		AS PrisonAbroadLast5Years --field does not exist in NTBS
			,NULL																		AS PrisonAbroadMoreThan5YearsAgo --field does not exist in NTBS
			,nacs.PCT_name																AS PCT
            ,nacs.HPU                                                                   AS HPU
			,hv.TreatmentHPU															AS TreatmentHPU
			,h.pctName																	AS HospitalPCT
			,la.[Name]																	AS HospitalLocalAuthority
			,nacs.HPU																	AS ResolvedResidenceHPU 
			,cd.ResidencePhec															AS ResolvedResidenceRegion 
			,ll.LTLAName																AS ResolvedResidenceLA
			,continent.[Name]															AS WorldRegionName
		FROM
			[dbo].[RecordRegister] rr
				INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = rr.NotificationId
				INNER JOIN [$(NTBS)].[dbo].[Patients] p ON p.NotificationId = rr.NotificationId
                INNER JOIN [$(NTBS)].[dbo].[ImmunosuppressionDetails] id ON id.NotificationId = rr.NotificationId
				INNER JOIN [$(NTBS)].[dbo].[ClinicalDetails] clinical ON clinical.NotificationId = p.NotificationId
				LEFT OUTER JOIN [$(NTBS)].[dbo].[DenotificationDetails] dn ON dn.NotificationId = rr.NotificationId
				LEFT OUTER JOIN [dbo].[DenotificationReasonMapping] drm ON drm.Reason = dn.Reason
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] pl ON pl.Pcode = p.PostcodeToLookup
				LEFT OUTER JOIN [$(ETS)].[dbo].[NACS_pctlookup] nacs ON nacs.PCT_code = pl.PctCode
				LEFT OUTER JOIN [$(ETS)].[dbo].[Hospital] h ON h.Id = cd.HospitalId
				LEFT OUTER JOIN [$(ETS)].[dbo].[LocalAuthority] la ON la.Code = h.LocalAuthorityCode
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].LTLALookup ll ON ll.Postcode = p.PostcodeToLookup
				INNER JOIN [$(NTBS)].[ReferenceData].Country c ON c.CountryId = p.CountryId
				LEFT OUTER JOIN [$(ETS)].[dbo].[Country] c2 ON c2.IsoCode = c.IsoCode
				LEFT OUTER JOIN [$(ETS)].[dbo].[Continent] continent ON continent.Id = c2.ContinentId
				LEFT OUTER JOIN [dbo].[LegacyExtractHospitalLookupValues] hv ON hv.HospitalId = cd.HospitalId
		WHERE rr.SourceSystem = 'NTBS'

		
		EXEC [dbo].[uspGenerateReportingLegacySitesOfDisease]

		EXEC [dbo].[uspGenerateReportingLegacyTOMFields]

		EXEC [dbo].[uspGenerateReportingLegacyTreatmentRegimen]

		--and then move over the ETS records
		INSERT INTO [dbo].[Record_LegacyExtract]([NotificationId]
          ,[LocalPatientId]
          ,[ReportYear]
          ,[DenotificationDate]
          ,[DenotificationComments]
          ,[Title]
          ,[AddressLine1]
          ,[AddressLine2]
          ,[Town]
          ,[County]
          ,[PCT]
          ,[HPU]
          ,[SitePulmonary]
          ,[SiteBoneSpine]
          ,[SiteBoneOther]
          ,[SiteCNSMeningitis]
          ,[SiteCNSOther]
          ,[SiteCryptic]
          ,[SiteGI]
          ,[SiteGU]
          ,[SiteITLymphNodes]
          ,[SiteLymphNode]
          ,[SiteLaryngeal]
          ,[SiteMiliary]
          ,[SitePleural]
          ,[SiteNonPulmonaryOther]
          ,[SiteNonPulmonaryUnknown]
          ,[OtherExtraPulmonarySite]
          ,[SiteUnknown]
          ,[MDRTreatment]
          ,[BcgVaccinationDate]
          ,[ShortCourse]
          ,[InPatient]
          ,[Comments]
          ,[ImmunosuppressionComments]
          ,[PrisonAbroadLast5Years]
          ,[PrisonAbroadMoreThan5YearsAgo]
          ,[TOMTreatmentInterruptedReason]
          ,[TOMTreatmentChangedReason]
          ,[TOMCompleteCourse]
          ,[TOMIncompleteReason]
          ,[TOMSubmittedDate]
          ,[TOMFollowUpResult]
          ,[TOMDeathDate]
          ,[TOMDeathRelationship]
          ,[TOMEndOfTreatmentDate]
          ,[TOMTreatmentRegimen]
          ,[TOMNonTuberculousMycobacteria]
          ,[TOMConversion]
          ,[TOMComment]
          ,[TOMReasonExceeds12mths]
          ,[TOMReported12mth]
          ,[TOMTreatmentInterruptedReason24mth]
          ,[TOMTreatmentChangedReason24mth]
          ,[TOMCompleteCourse24mth]
          ,[TOMIncompleteReason24mth]
          ,[TOMSubmittedDate24mth]
          ,[TOMFollowUpResult24mth]
          ,[TOMDeathDate24mth]
          ,[TOMDeathRelationship24mth]
          ,[TOMEndOfTreatmentDate24mth]
          ,[TOMTreatmentRegimen24mth]
          ,[TOMNonTuberculousMycobacteria24mth]
          ,[TOMConversion24mth]
          ,[TOMComment24mth]
          ,[TOMReported24mth]
          ,[TreatmentHPU]
          ,[HospitalPCT]
          ,[HospitalLocalAuthority]
          ,[ResolvedResidenceHPU]
          ,[ResolvedResidenceRegion]
          ,[ResolvedResidenceLA]
          ,[NoSampleTaken]
          ,[TOMTreatmentInterruptedReason36mth]
          ,[TOMTreatmentChangedReason36mth]
          ,[TOMCompleteCourse36mth]
          ,[TOMIncompleteReason36mth]
          ,[TOMSubmittedDate36mth]
          ,[TOMFollowUpResult36mth]
          ,[TOMDeathDate36mth]
          ,[TOMDeathRelationship36mth]
          ,[TOMEndOfTreatmentDate36mth]
          ,[TOMTreatmentRegimen36mth]
          ,[TOMNonTuberculousMycobacteria36mth]
          ,[TOMConversion36mth]
          ,[TOMComment36mth]
          ,[TOMReported36mth]
          ,[TOMReasonExceeds24mths]
          ,[WorldRegionName])

        SELECT
           rr.[NotificationId]
          ,[LocalPatientId]
          ,DATEPART(YEAR, rr.NotificationDate)		                                AS ReportYear
          ,[DenotificationDate]
          ,[DenotificationComments]
          ,[Title]
          ,[AddressLine1]
          ,[AddressLine2]
          ,[Town]
          ,[county]
          ,[PCT]
          ,[HPU]
          ,[SitePulmonary]
          ,[SiteBoneSpine]
          ,[SiteBoneOther]
          ,[SiteCNSMeningitis]
          ,[SiteCNSOther]
          ,[SiteCryptic]
          ,[SiteGI]
          ,[SiteGU]
          ,[SiteITLymphNodes]
          ,[SiteLymphNode]
          ,[SiteLaryngeal]
          ,[SiteMiliary]
          ,[SitePleural]
          ,[SiteNonPulmonaryOther]
          ,[SiteNonPulmonaryUnknown]
          ,[OtherExtraPulmonarySite]
          ,[SiteUnknown]
          ,[MDRTreatment]
          ,[BcgVaccinationDate]
          ,[ShortCourse]
          ,[InPatient]
          ,[Comments]
          ,LEFT([OtherComments], 60) AS ImmunosuppressionComments
          ,[PrisonAbroadLast5Years]
          ,[PrisonAbroadMoreThan5YearsAgo]
          ,[TOMTreatmentInterruptedReason]
          ,[TOMTreatmentChangedReason]
          ,[TOMCompleteCourse]
          ,[TOMIncompleteReason]
          ,[TOMSubmittedDate]
          ,[TOMFollowUpResult]
          ,[TOMDeathDate]
          ,[TOMDeathRelationship]
          ,[TOMEndOfTreatmentDate]
          ,[TOMTreatmentRegimen]
          ,[TOMNonTuberculousMycobacteria]
          ,[TOMConversion]
          ,LEFT([TOMComment], 500) AS TOMComment
          ,[TOMReasonExceeds12mths]
          ,[TOMReported12mth]
          ,[TOMTreatmentInterruptedReason24mth]
          ,[TOMTreatmentChangedReason24mth]
          ,[TOMCompleteCourse24mth]
          ,[TOMIncompleteReason24mth]
          ,[TOMSubmittedDate24mth]
          ,[TOMFollowUpResult24mth]
          ,[TOMDeathDate24mth]
          ,[TOMDeathRelationship24mth]
          ,[TOMEndOfTreatmentDate24mth]
          ,[TOMTreatmentRegimen24mth]
          ,[TOMNonTuberculousMycobacteria24mth]
          ,[TOMConversion24mth]
          ,[TOMComment24mth]
          ,[TOMReported24mth]
          ,[TreatementHPU] --this spelling mistake is deliberate, the field is spelt wrong in ETS
          ,[HospitalPCT]
          ,[HospitalLocalAuthority]
          ,[ResolvedResidenceHPU]
          ,[ResolvedResidenceRegion]
          ,[ResolvedResidenceLA]
          ,[NoSampleTaken]
          ,[TOMTreatmentInterruptedReason36mth]
          ,[TOMTreatmentChangedReason36mth]
          ,[TOMCompleteCourse36mth]
          ,[TOMIncompleteReason36mth]
          ,[TOMSubmittedDate36mth]
          ,[TOMFollowUpResult36mth]
          ,[TOMDeathDate36mth]
          ,[TOMDeathRelationship36mth]
          ,[TOMEndOfTreatmentDate36mth]
          ,[TOMTreatmentRegimen36mth]
          ,[TOMNonTuberculousMycobacteria36mth]
          ,[TOMConversion36mth]
          ,[TOMComment36mth]
          ,[TOMReported36mth]
          ,[TOMReasonExceeds24mths]
          ,[WorldRegionName]
    FROM [$(ETS)].[dbo].[DataExportMainTable] de
        INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = de.Id
    WHERE rr.SourceSystem = 'ETS'

END TRY
BEGIN CATCH
	THROW
END CATCH
