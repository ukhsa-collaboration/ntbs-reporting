CREATE PROCEDURE [dbo].[uspSummarisedLabMatchComparison]
	@StartDate DATE
AS
	WITH MatchScenarios AS
	(
		SELECT Scenario, ScenarioDescription
			FROM [dbo].[vwComparisonOfLabMatchScenarios]),

	CountOfScenarios AS
	(
	SELECT Scenario, COUNT(ReferenceLaboratoryNumber) AS NumberOfMatches
		FROM [dbo].vwComparisonOfLabMatches
	WHERE MatchDate >= @StartDate
	GROUP BY Scenario
)

SELECT ms.Scenario, ms.ScenarioDescription, COALESCE(cs.NumberOfMatches, 0) AS NumberOfMatches
	FROM MatchScenarios ms
	LEFT OUTER JOIN CountOfScenarios cs ON cs.Scenario = ms.Scenario
RETURN 0
