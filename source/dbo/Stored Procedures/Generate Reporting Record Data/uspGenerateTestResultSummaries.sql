CREATE PROCEDURE [dbo].[uspGenerateTestResultSummaries]

AS
	EXEC [dbo].[uspGenerateSputumResult];
    EXEC [dbo].[uspGenerateInitialSputumResults];

	SELECT DISTINCT rr.NotificationId, ManualTestTypeId,
		FIRST_VALUE(rra.DisplayName) OVER (PARTITION BY rr.NotificationId, mtr.ManualTestTypeId ORDER BY
			rra.[Rank], rra.[SubRank]) AS Result
	INTO #TempManualTestResult
		FROM RecordRegister rr
			INNER JOIN [$(NTBS)].[dbo].[ManualTestResult] mtr ON rr.NotificationId = mtr.NotificationId
			INNER JOIN ManualTestResultRanking rra ON rra.ResultName = mtr.Result
		WHERE rr.SourceSystem = 'NTBS' AND mtr.ManualTestTypeId NOT IN (4, 7);

	UPDATE cd
    SET cd.SmearSummary =
            COALESCE(
				(SELECT Result FROM #TempManualTestResult tmtr
					WHERE tmtr.NotificationId = rr.NotificationId AND ManualTestTypeId = 1)
				,'No result'),
        cd.CultureSummary =
            COALESCE(
				(SELECT Result FROM #TempManualTestResult tmtr
					WHERE tmtr.NotificationId = rr.NotificationId AND ManualTestTypeId = 2)
				,'No result'),
		cd.HistologySummary =
            COALESCE(
				(SELECT Result FROM #TempManualTestResult tmtr
					WHERE tmtr.NotificationId = rr.NotificationId AND ManualTestTypeId = 3)
				,'No result'),
		cd.PCRSummary =
            COALESCE(
				(SELECT Result FROM #TempManualTestResult tmtr
					WHERE tmtr.NotificationId = rr.NotificationId AND ManualTestTypeId = 5)
				,'No result'),
		cd.LineProbeAssaySummary =
            COALESCE(
				(SELECT Result FROM #TempManualTestResult tmtr
					WHERE tmtr.NotificationId = rr.NotificationId AND ManualTestTypeId = 6)
				,'No result')
    FROM [dbo].[Record_CaseData] cd
        INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
	WHERE rr.SourceSystem = 'NTBS'
    
	DROP TABLE #TempManualTestResult;
