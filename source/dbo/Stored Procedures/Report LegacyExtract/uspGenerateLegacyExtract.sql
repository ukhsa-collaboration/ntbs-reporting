CREATE PROCEDURE [dbo].[uspGenerateLegacyExtract]
	
AS
	--clear table
	DELETE FROM [dbo].[LegacyExtract]

	--add a record for every row in ReusableNotification and Denotified Records

	INSERT INTO [dbo].[LegacyExtract] (NotificationId, SourceSystem)
		SELECT NotificationId, SourceSystem FROM [dbo].[ReusableNotification]
		WHERE SourceSystem = 'NTBS'
		UNION
		SELECT NotificationId, SourceSystem FROM [dbo].[DenotifiedRecords]

	--now populate for NTBS records

	UPDATE [dbo].[LegacyExtract]
		SET LocalPatientId = COALESCE(p.LocalPatientId, ''),
		AddressLine1 = COALESCE(p.[Address], ''),
		BcgVaccinationDate = cd.BCGVaccinationYear,
		DOT = [dbo].ufnGetLegacyDOTvalue(cd.DotStatus),
		InPatient = 'Not known',
		Comments = COALESCE(LEFT(cd.Notes, 500), ''),
		HIVTestOffered =  [dbo].[ufnGetHIVValue](cd.HIVTestState),
		ProposedDrugRegimen = '',
		OtherImmunosuppressionComments = COALESCE(id.OtherDescription, ''),
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



RETURN 0
