/***************************************************************************************************
Desc:    This returns the Organism/Species drop-down values, eg "M. bovies", "M. africanum" ...


         
**************************************************************************************************/

CREATE VIEW [dbo].[vwSpecies] AS
	SELECT Top 10
		OrganismName,
		SortOrder
	FROM (
			SELECT
				'All' AS OrganismName,
				0 AS SortOrder
			UNION
			SELECT
				OrganismName,
				SortOrder
			FROM Organism
		) Species
	ORDER BY SortOrder
