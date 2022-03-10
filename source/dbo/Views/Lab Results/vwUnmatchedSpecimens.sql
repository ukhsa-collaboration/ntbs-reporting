CREATE VIEW [dbo].[vwUnmatchedSpecimens]
	AS 

	WITH NoMatchesFound AS
	(
		SELECT ls.ReferenceLaboratoryNumber
		FROM [$(NTBS_Specimen_Matching)].dbo.LabSpecimen ls
		INNER JOIN vwNotificationYear ny ON ny.NotificationYear = YEAR(ls.SpecimenDate)
		LEFT JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
		WHERE nsm.MatchType IS NULL
	),

	MatchTypeRanking AS
	(

		SELECT 1 AS [Rank], 'Confirmed' AS ResultName
		UNION
		SELECT 1 AS [Rank], 'Possible' AS ResultName
		UNION
		SELECT 2 AS [Rank], 'Rejected-Possible' AS ResultName
		UNION
		SELECT 2 AS [Rank], 'Rejected' AS ResultName
	),

	AllMatchesRejected AS
	(
		SELECT ranked.ReferenceLaboratoryNumber FROM (
			SELECT DISTINCT nsm.ReferenceLaboratoryNumber, FIRST_VALUE(mtr.ResultName) OVER (PARTITION BY nsm.ReferenceLaboratoryNumber ORDER BY mtr.[rank] ASC) AS [Result]
			FROM [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm
			INNER JOIN [$(NTBS_Specimen_Matching)].dbo.LabSpecimen ls ON ls.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber
			INNER JOIN vwNotificationYear ny ON ny.NotificationYear = YEAR(ls.SpecimenDate)
			INNER JOIN MatchTypeRanking mtr ON mtr.ResultName = nsm.MatchType) ranked
		WHERE ranked.Result = 'Rejected' OR ranked.Result = 'Rejected-Possible'
	),

	UnmatchedSpecimens AS
	(
		SELECT * FROM NoMatchesFound 
		UNION 
		SELECT * FROM AllMatchesRejected
	)

	SELECT DISTINCT ls.[ReferenceLaboratoryNumber]
			,ls.[SpecimenDate]
			,ls.[SpecimenTypeCode] AS SampleType
			,ls.[LaboratoryName]
			,ls.[ReferenceLaboratory]
			,ls.[Species]
			,CASE WHEN ls.[INH] = 'Sensitive' THEN 'S'
				WHEN ls.[INH] = 'Resistant' THEN 'R'
				WHEN ls.[INH] = 'No result' THEN 'N' ELSE NULL END AS [INH]
			,CASE WHEN ls.RIF = 'Sensitive' THEN 'S'
				WHEN ls.RIF = 'Resistant' THEN 'R'
				WHEN ls.RIF = 'No result' THEN 'N' ELSE NULL END AS [RIF]
			,CASE WHEN ls.PZA = 'Sensitive' THEN 'S'
				WHEN ls.PZA = 'Resistant' THEN 'R'
				WHEN ls.PZA = 'No result' THEN 'N' ELSE NULL END AS [PZA]
			,CASE WHEN ls.EMB = 'Sensitive' THEN 'S'
				WHEN ls.EMB = 'Resistant' THEN 'R'
				WHEN ls.EMB = 'No result' THEN 'N' ELSE NULL END AS [EMB]
			,ls.[MDR]
			,ls.[AMINO]
			,ls.[QUIN]
			,ls.[XDR]
			,ls.[PatientNhsNumber]
			,ls.[PatientBirthDate]
			,ls.[PatientName]
			,ls.[PatientSex]
			,ls.[PatientAddress]
			,ls.[PatientPostcode]
			,ls.[EarliestRecordDate]
			-- Take first value over partition as each lab name can have multiple mappings, 
			-- some of which lead to null regions, others which don't
			,FIRST_VALUE(p.[Code]) OVER (PARTITION BY us.ReferenceLaboratoryNumber ORDER BY p.[Code] DESC) AS RegionCode
			,FIRST_VALUE(p.[Name]) OVER (PARTITION BY us.ReferenceLaboratoryNumber ORDER BY p.[Code] DESC) AS Region
		FROM UnmatchedSpecimens us
		JOIN [$(NTBS_Specimen_Matching)].dbo.LabSpecimen ls ON ls.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
		LEFT JOIN [$(ETS)].dbo.LaboratoryHospitalMapping lhm ON lhm.SourceLabName = ls.LaboratoryName
		LEFT JOIN [$(NTBS)].ReferenceData.Hospital hd ON lhm.HospitalId = hd.HospitalId
		LEFT JOIN [$(NTBS)].ReferenceData.TbService tb ON hd.TBServiceCode = tb.Code
		LEFT JOIN [$(NTBS)].ReferenceData.PHEC p ON p.Code = tb.PHECCode
		WHERE lhm.AuditDelete IS NULL
