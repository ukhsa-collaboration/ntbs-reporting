CREATE VIEW [dbo].[vwComparisonOfLabMatchScenarios]
	AS
	SELECT 1 AS Scenario, 'matched to same record in ETS and NTBS' AS ScenarioDescription
	UNION
	SELECT 2 AS Scenario, 'matched to record only in ETS' AS ScenarioDescription
	UNION
	SELECT 3 AS Scenario, 'matched to record only in NTBS' AS ScenarioDescription
	UNION
	SELECT 4 AS Scenario, 'matched to two completely separate records in ETS and NTBS' AS ScenarioDescription
	UNION
	SELECT 5 AS Scenario, 'matched to NTBS half of a migrated record only' AS ScenarioDescription
	UNION
	SELECT 6 AS Scenario, 'matched to ETS half of a migrated record only' AS ScenarioDescription
	UNION
	SELECT 7 AS Scenario, 'matched to NTBS half of a migrated record + different ETS record' AS ScenarioDescription
	UNION
	SELECT 8 AS Scenario, 'matched to ETS half of a migrated record + different NTBS record' AS ScenarioDescription








