CREATE PROCEDURE [dbo].[uspGenerateReportingLegacySitesOfDisease]
AS
BEGIN TRY

	-- perform the update
	UPDATE le
		SET SitePulmonary = dbo.ufnMapYesNoToBooleanText(cd.[Pulmonary site]),
		SiteBoneSpine = dbo.ufnMapYesNoToBooleanText(cd.[Spine site]),
		SiteBoneOther = dbo.ufnMapYesNoToBooleanText(cd.[Bone/joint: Other site]),
		SiteCNSMeningitis = dbo.ufnMapYesNoToBooleanText(cd.[Meningitis site]),
		SiteCNSOther = dbo.ufnMapYesNoToBooleanText(cd.[CNS: Other site]),
		SiteCryptic = dbo.ufnMapYesNoToBooleanText(cd.[Cryptic disseminated site]),
		SiteGI = dbo.ufnMapYesNoToBooleanText(cd.[Gastrointestinal/peritoneal site]),
		SiteGU = dbo.ufnMapYesNoToBooleanText(cd.[Genitourinary site]),
		SiteITLymphNodes = dbo.ufnMapYesNoToBooleanText(cd.[Lymph nodes: Intra-thoracic site]),
		SiteLymphNode = dbo.ufnMapYesNoToBooleanText(cd.[Lymph nodes: Extra-thoracic site]),
		SiteLaryngeal = dbo.ufnMapYesNoToBooleanText(cd.[Laryngeal site]),
		SiteMiliary = dbo.ufnMapYesNoToBooleanText(cd.[Miliary site]),
		SitePleural = dbo.ufnMapYesNoToBooleanText(cd.[Pleural site]),
		SiteNonPulmonaryOther = CASE
			WHEN 'Yes' IN (cd.[Ocular site], cd.[Pericardial site], cd.[Soft tissue/Skin site], cd.[Other extra-pulmonary site]) THEN 'TRUE'
			ELSE 'FALSE' END,
		SiteNonPulmonaryUnknown = 'FALSE',
		SiteUnknown = 'FALSE'
		FROM [dbo].[Record_LegacyExtract] le
			INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = le.NotificationId

	--Add in the OtherExtraPulmonarySite text
	UPDATE le
		SET OtherExtraPulmonarySite = ns.SiteDescription
	FROM [dbo].[Record_LegacyExtract] le
		INNER JOIN [$(NTBS)].[dbo].[NotificationSite] ns ON ns.NotificationId = le.NotificationId
	WHERE ns.SiteId = 17 -- Other extra-pulmonary

END TRY
BEGIN CATCH
	THROW
END CATCH
