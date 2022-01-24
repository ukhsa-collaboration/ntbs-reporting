CREATE PROCEDURE [dbo].[uspGenerateInitialSputumResults]

AS
	WITH

	ResultRanking AS
	(
		SELECT 1 AS Rank, 1 AS SubRank, 'Positive' AS ResultName, 'Positive' AS DisplayName
		UNION
		SELECT 1 AS Rank, 2 AS SubRank, 'Negative' AS ResultName, 'Negative' AS ResultName
		UNION
		SELECT 2 AS Rank, NULL AS SubRank, 'NoResultAvailable' AS ResultName, 'No result available' AS ResultName
		UNION
		SELECT 3 AS Rank, NULL AS SubRank, 'Awaiting' AS ResultName, 'Awaiting' AS ResultName
	),

	NtbsInitialSputumSmearResults AS 
	(
		SELECT DISTINCT 
           	rr.NotificationId, 
            	rr.SourceSystem, 
           	FIRST_VALUE(rra.[DisplayName]) OVER (PARTITION BY rr.NotificationId ORDER BY rra.[Rank], mtr.TestDate, rra.[SubRank]) AS InitialSputumSmearResult
		FROM [$(NTBS)].[dbo].[ManualTestResult] mtr
			JOIN [dbo].[RecordRegister] rr on rr.NotificationId = mtr.NotificationId
			INNER JOIN ResultRanking rra ON rra.ResultName = mtr.Result
		WHERE mtr.ManualTestTypeId=1 
		AND mtr.SampleTypeId IN (4,5) 
		AND rr.SourceSystem='NTBS'
	),

	NtbsInitialSputumPCRResults AS
	(
		SELECT DISTINCT 
           	rr.NotificationId,
	  		rr.SourceSystem, 
           	FIRST_VALUE(rra.[DisplayName]) OVER (PARTITION BY rr.NotificationId ORDER BY rra.[Rank], mtr.TestDate, rra.[SubRank]) AS InitialSputumPCRResult
		FROM [$(NTBS)].[dbo].[ManualTestResult] mtr
			JOIN [dbo].[RecordRegister] rr on rr.NotificationId = mtr.NotificationId
			INNER JOIN ResultRanking rra ON rra.ResultName = mtr.Result
		WHERE mtr.ManualTestTypeId=5 
		AND mtr.SampleTypeId IN (4,5) 
		AND rr.SourceSystem='NTBS'
	)

    UPDATE cd
    SET cd.InitialSputumSmearResult =
            (CASE
                WHEN sr.InitialSputumSmearResult IS NOT NULL THEN sr.InitialSputumSmearResult
                ELSE 'No result'
                END),
        cd.InitialSputumPCRResult =
            (CASE
                WHEN pr.InitialSputumPCRResult IS NOT NULL THEN pr.InitialSputumPCRResult
                ELSE 'No result'
                END)
    FROM [dbo].[Record_CaseData] cd
        INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
        LEFT OUTER JOIN NtbsInitialSputumSmearResults sr ON sr.NotificationId = cd.NotificationId AND sr.SourceSystem = rr.SourceSystem
        LEFT OUTER JOIN NtbsInitialSputumPCRResults pr ON pr.NotificationId = cd.NotificationId AND sr.SourceSystem = rr.SourceSystem
    