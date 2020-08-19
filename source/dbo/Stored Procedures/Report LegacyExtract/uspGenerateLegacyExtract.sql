CREATE PROCEDURE [dbo].[uspGenerateLegacyExtract]
	
AS
	BEGIN TRY
		
		--fields which are already in ReusableNotification have been moved over already
		--now to update those which only live in the LegacyExtract
		UPDATE [dbo].[LegacyExtract]
			SET LocalPatientId = COALESCE(p.LocalPatientId, ''),
			AddressLine1 = COALESCE(p.[Address], ''),
			AddressLine2 = '',
			Town = '',
			County = '',
			BcgVaccinationDate = COALESCE(CONVERT(NVARCHAR(5), cd.BCGVaccinationYear), ''),
			DOT = [dbo].ufnGetLegacyDOTvalue(cd.DotStatus),
			InPatient = 'Not known',
			OtherExtraPulmonarySite = COALESCE(ns.[SiteDescription], ''),
			Comments = COALESCE(LEFT(cd.Notes, 500), ''),
			HIVTestOffered =  [dbo].[ufnGetHIVValue](cd.HIVTestState),
			ProposedDrugRegimen = '',
			ImmunosuppressionComments = COALESCE(LEFT(id.OtherDescription, 50), ''),
			PCT = COALESCE(pl.PctCode, ''),
			HospitalPCT = COALESCE(h.pctName, ''),
			HospitalLocalAuthority = COALESCE(la.[Name], ''),
			WorldRegionName = continent.[Name]
			FROM 
				[$(NTBS)].[dbo].[Patients] p
				INNER JOIN [$(NTBS)].[dbo].[ClinicalDetails] cd ON cd.NotificationId = p.NotificationId
				INNER JOIN [$(NTBS)].[dbo].[ImmunosuppressionDetails] id ON id.NotificationId = p.NotificationId
				LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] pl ON pl.Pcode = REPLACE(p.Postcode, ' ', '')
				INNER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = p.NotificationId
				LEFT OUTER JOIN [$(NTBS)].[dbo].[NotificationSite] ns ON ns.NotificationId = p.NotificationId AND ns.SiteId = 17
				LEFT OUTER JOIN [$(ETS)].[dbo].[Hospital] h ON h.Id = hd.HospitalId
				LEFT OUTER JOIN [$(ETS)].[dbo].[LocalAuthority] la ON la.Code = h.LocalAuthorityCode
				INNER JOIN [$(NTBS)].[ReferenceData].Country c ON c.CountryId = p.CountryId
				LEFT OUTER JOIN [$(ETS)].[dbo].[Country] c2 ON c2.IsoCode = c.IsoCode
				LEFT OUTER JOIN [$(ETS)].[dbo].[Continent] continent ON continent.Id = c2.ContinentId
				INNER JOIN [dbo].[LegacyExtract] le1 ON le1.NotificationId = p.NotificationId AND le1.SourceSystem = 'NTBS'

	
		--second pass to derive HPU from PCT
	
		UPDATE [dbo].[LegacyExtract]
			SET HPU = COALESCE(nacs.HPU, '')
			FROM [$(ETS)].[dbo].[NACS_pctlookup] nacs
			RIGHT OUTER JOIN [dbo].[LegacyExtract] le1 ON le1.PCT = nacs.PCT_code

		EXEC [dbo].[uspUpdateLegacySitesOfDisease]

	END TRY
	BEGIN CATCH
		THROW
	END CATCH

RETURN 0
