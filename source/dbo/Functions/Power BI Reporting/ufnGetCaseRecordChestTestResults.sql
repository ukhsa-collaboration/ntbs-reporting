CREATE FUNCTION [dbo].[ufnGetCaseRecordChestTestResults](
	@NotificationId INT,
	@TestTypeId INT,
	@DiagnosisDate DATETIME2
)
RETURNS TABLE
AS
RETURN (
	SELECT TOP(1) resultLookup.FormattedResult AS ChestTestResult
	FROM [$(NTBS)].[dbo].[ManualTestResult] mr
		LEFT JOIN [ChestTestResultLookup] resultLookup ON resultLookup.Result = mr.Result
	WHERE NotificationId = @NotificationId AND mr.ManualTestTypeId = @TestTypeId
	ORDER BY ABS(DATEDIFF(day, mr.TestDate, @DiagnosisDate)) ASC, resultLookup.Ranking ASC
)
