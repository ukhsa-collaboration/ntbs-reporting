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
		,CASE WHEN Result = 'ConsistentWithTbCavities' THEN 1
			WHEN Result = 'ConsistentWithTbOther' THEN 2
			WHEN Result = 'NotConsistentWithTb' THEN 3
			WHEN Result = 'Awaiting' THEN 4 END ASC
		) AS rn
	FROM [$(NTBS)].[dbo].[ManualTestResult] mr
		INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = mr.NotificationId
	WHERE ManualTestTypeId = 4
	)
	UPDATE cd
	SET ChestXRayResult =
	CASE
	WHEN rankedResults.result = 'Awaiting' THEN 'Awaiting'
	WHEN rankedResults.result = 'NotConsistentWithTb' THEN 'Not consistent with TB'
	WHEN rankedResults.result = 'ConsistentWithTbCavities' THEN 'Consistent with TB - cavities'
	WHEN rankedResults.result = 'ConsistentWithTbOther' THEN 'Consistent with TB - other'
	ELSE 'No result'
	END
	
	FROM [dbo].[Record_CaseData] cd
		LEFT OUTER JOIN rankedResults rankedResults ON rankedResults.NotificationId = cd.NotificationId AND rankedResults.rn = 1

END TRY
BEGIN CATCH
	THROW
END CATCH
