CREATE PROCEDURE [dbo].[uspGenerateUnmatchedSpecimens]
AS
BEGIN TRY

	TRUNCATE TABLE [dbo].[UnmatchedSpecimens]

	SELECT ls.ReferenceLaboratoryNumber 
	INTO #NoMatchesFound
		FROM [$(NTBS_Specimen_Matching)].dbo.LabSpecimen ls
		INNER JOIN vwNotificationYear ny ON ny.NotificationYear = YEAR(ls.SpecimenDate)
		LEFT JOIN [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm ON nsm.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
		WHERE nsm.MatchType IS NULL

	CREATE TABLE #MatchTypeRanking ([Rank] int, ResultName nvarchar(20) )

	INSERT INTO #MatchTypeRanking VALUES (1, 'Confirmed')
	INSERT INTO #MatchTypeRanking VALUES (1, 'Possible')
	INSERT INTO #MatchTypeRanking VALUES (2, 'Rejected-Possible')
	INSERT INTO #MatchTypeRanking VALUES (2, 'Rejected')

	SELECT ranked.ReferenceLaboratoryNumber INTO #AllMatchesRejected FROM (
		SELECT DISTINCT nsm.ReferenceLaboratoryNumber, FIRST_VALUE(mtr.[Rank]) OVER (PARTITION BY nsm.ReferenceLaboratoryNumber ORDER BY mtr.[rank] ASC) AS [Rank]
			FROM [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch nsm
			INNER JOIN [$(NTBS_Specimen_Matching)].dbo.LabSpecimen ls ON ls.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber
			INNER JOIN vwNotificationYear ny ON ny.NotificationYear = YEAR(ls.SpecimenDate)
			INNER JOIN #MatchTypeRanking mtr ON mtr.ResultName = nsm.MatchType
			) ranked
		WHERE ranked.[Rank] = 2

	CREATE TABLE #UnmatchedSpecimens (ReferenceLaboratoryNumber NVARCHAR(50))
	INSERT INTO #UnmatchedSpecimens SELECT * FROM #NoMatchesFound
	INSERT INTO #UnmatchedSpecimens SELECT * FROM #AllMatchesRejected

	INSERT INTO [dbo].[UnmatchedSpecimens] SELECT DISTINCT ls.[ReferenceLaboratoryNumber]
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
			,phec.[Code] AS RegionCode
			,phec.[Name] AS Region
		FROM #UnmatchedSpecimens us
		JOIN [$(NTBS_Specimen_Matching)].dbo.LabSpecimen ls ON ls.ReferenceLaboratoryNumber = us.ReferenceLaboratoryNumber
		LEFT JOIN [$(NTBS_Specimen_Matching)].dbo.LabHospitalRegionMapping mapping ON mapping.LaboratoryName = ls.LaboratoryName
		LEFT JOIN [$(NTBS)].ReferenceData.PHEC phec ON phec.Code = mapping.RegionCode

	DROP TABLE #NoMatchesFound
	DROP TABLE #MatchTypeRanking
	DROP TABLE #AllMatchesRejected
	DROP TABLE #UnmatchedSpecimens

	EXEC dbo.uspGenerateUnmatchedSpecimensLinkedNotifications


END TRY
BEGIN CATCH
	THROW
END CATCH