/*Summarise the sputum results for each case, across all test types
TODO: this may exclude culture
If the case has both positive and negative results, display positive.
If the case has no results, or only awaiting/unknown values display 'Unknown' */



CREATE PROCEDURE [dbo].[uspGenerateSputumResult]
	
AS
	WITH

	ResultRanking AS
	(

		SELECT 1 AS [Rank], 'Positive' AS ResultName
		UNION
		SELECT 2 AS [Rank], 'Negative' AS ResultName
		UNION
		SELECT 3 AS [Rank], 'Awaiting' AS ResultName
		UNION
		SELECT 4 AS [Rank], 'Not known' AS ResultName
	),

	EtsSputumResults AS
	(
		SELECT DISTINCT rr.NotificationId, rr.SourceSystem, FIRST_VALUE(lrc.[Name]) OVER (PARTITION BY rr.NotificationId ORDER BY rra.[Rank]) AS ResultName
		FROM
			[$(ETS)].[dbo].[Notification] n
				INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = n.LegacyId AND rr.SourceSystem = 'ETS'
				INNER JOIN [$(ETS)].[dbo].[LaboratoryResult] lr ON lr.NotificationId = n.Id
				INNER JOIN [$(ETS)].[dbo].[LaboratoryResultCode] lrc ON lrc.LegacyId = lr.Result
				INNER JOIN ResultRanking rra ON rra.ResultName = lrc.[Name]
			WHERE lr.OpieId IS NULL AND lr.AuditDelete IS NULL
			AND lr.SpecimenTypeId IN 
				('CCDA4562-015E-4CA7-B767-45A2940BE4F6',
				'E3A89A3E-E80D-48D8-9823-76542228AC1C',
				'44AE75D3-F654-49C2-8F93-DBA9EA74F164', 
				'579C7E52-F824-4642-BC5D-167E4510BA10')
			--test types of microscopy and molecular amplification
			AND lr.LaboratoryCategoryId IN ( '2D413D16-28E3-48DB-A661-8099226CB6A3', 'A26602F1-DC05-4E9F-AC48-445B62797D81')
	),

	NtbsSputumResults AS
	(
		SELECT DISTINCT rr.NotificationId, rr.SourceSystem, FIRST_VALUE(mtr.[Result]) OVER (PARTITION BY rr.NotificationId ORDER BY rra.[Rank]) AS ResultName
		FROM [$(NTBS)].[dbo].[ManualTestResult] mtr 
			INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = mtr.NotificationId
			INNER JOIN ResultRanking rra ON rra.ResultName = mtr.Result
		WHERE mtr.SampleTypeId IN (4, 5)
		--test types of Smear and PCR
		AND mtr.ManualTestTypeId IN (1, 5)
		
	),

	AllSputumResults AS
	(

		SELECT * FROM NtbsSputumResults
		UNION
		SELECT * FROM EtsSputumResults

	)

	UPDATE cd
		SET cd.SputumResult = 
			(CASE ar.ResultName
				WHEN 'Positive' THEN 'Positive'
				WHEN 'Negative' THEN 'Negative'
				ELSE 'Unknown'
			END)

	FROM [dbo].[Record_CaseData] cd
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
		LEFT OUTER JOIN AllSputumResults ar ON ar.NotificationId = cd.NotificationId AND ar.SourceSystem = rr.SourceSystem