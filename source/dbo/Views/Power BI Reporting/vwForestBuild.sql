CREATE VIEW [dbo].[vwForestBuild]
	AS 
	SELECT [BuildNumber], [LastExtractionDate]
	FROM [$(NTBS_Specimen_Matching)].[dbo].[ForestClusterBuild]
