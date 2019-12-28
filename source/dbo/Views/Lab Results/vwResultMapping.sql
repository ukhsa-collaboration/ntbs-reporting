CREATE VIEW [dbo].[vwResultMapping]
	AS SELECT DISTINCT rm.ResultOutputName, rm.[Rank]  FROM [dbo].ResultMapping rm
