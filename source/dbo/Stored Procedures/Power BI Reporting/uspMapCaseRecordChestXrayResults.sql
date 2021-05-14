CREATE PROCEDURE [dbo].[uspMapCaseRecordChestXrayResults]
AS
BEGIN TRY

	WITH rankedResults AS
	(
	SELECT mr.NotificationId
	,mr.Result AS result
	,ROW_NUMBER() OVER
		(PARTITION BY mr.NotificationId
		ORDER BY ABS(DATEDIFF(day, mr.TestDate, cd.DiagnosisDate)) ASC
		,resultLookup.Ranking ASC
		) AS rn
	FROM [$(NTBS)].[dbo].[ManualTestResult] mr
		INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = mr.NotificationId
		LEFT JOIN ChestXrayResultLookup resultLookup ON resultLookup.Result = mr.Result
	WHERE ManualTestTypeId = 4
	)
	UPDATE cd
	SET ChestXRayResult = COALESCE(resultLookup.FormattedResult, 'No result')
	FROM [dbo].[Record_CaseData] cd
		LEFT OUTER JOIN rankedResults ON rankedResults.NotificationId = cd.NotificationId AND rankedResults.rn = 1
		LEFT JOIN ChestXrayResultLookup resultLookup ON resultLookup.Result = rankedResults.result

END TRY
BEGIN CATCH
	THROW
END CATCH
