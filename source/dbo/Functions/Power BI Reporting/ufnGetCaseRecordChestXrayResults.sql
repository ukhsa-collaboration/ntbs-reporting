CREATE FUNCTION [dbo].[ufnGetCaseRecordChestXrayResults](
	@NotificationId INT,
	@DiagnosisDate DATETIME2
)
RETURNS TABLE
AS
RETURN (
	SELECT TOP(1) resultLookup.FormattedResult AS ChestXRayResult
	FROM [$(NTBS)].[dbo].[ManualTestResult] mr
		LEFT JOIN ChestXrayResultLookup resultLookup ON resultLookup.Result = mr.Result
	WHERE NotificationId = @NotificationId AND mr.ManualTestTypeId = 4
	ORDER BY ABS(DATEDIFF(day, mr.TestDate, @DiagnosisDate)) ASC, resultLookup.Ranking ASC
)
