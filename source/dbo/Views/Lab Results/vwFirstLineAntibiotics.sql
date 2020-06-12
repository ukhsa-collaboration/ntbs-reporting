CREATE VIEW [dbo].[vwFirstLineAntibiotics]
	AS 
	SELECT 'INH' AS 'AntibioticOutputName', 1 AS 'SortOrder'
	UNION
	SELECT 'RIF' AS 'AntibioticOutputName', 2 AS 'SortOrder'
	UNION
	SELECT 'EMB' AS 'AntibioticOutputName', 3 AS 'SortOrder'
	UNION
	SELECT 'PZA' AS 'AntibioticOutputName', 4 AS 'SortOrder'
