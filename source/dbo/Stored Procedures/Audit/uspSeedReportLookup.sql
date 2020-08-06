CREATE PROCEDURE [dbo].[uspSeedReportLookup]
	
AS
	DELETE FROM [dbo].ReportLookup

	INSERT INTO [dbo].ReportLookup (ItemId, ReportName)
		
		SELECT C.ItemID, C.[Name] FROM [$(ReportServer)].[dbo].[Catalog] C 
		WHERE C.[Type] = 2

	UPDATE [dbo].ReportLookup SET ReportGroup = 'Audit' WHERE ReportName like '%Audit%'

	UPDATE [dbo].ReportLookup SET ReportGroup = 'CultureResistance' WHERE ReportName like '%Resistance%'

	UPDATE [dbo].ReportLookup SET ReportGroup = 'DataQuality' WHERE ReportName like '%Quality%'
	
	UPDATE [dbo].ReportLookup SET ReportGroup = 'Notification' WHERE ReportName like '%Notification%'

	UPDATE [dbo].ReportLookup SET ReportGroup = 'Enhanced' WHERE ReportName like '%Enhanced%'

	UPDATE [dbo].ReportLookup SET ReportGroup = 'Outcome' WHERE ReportName like '%Outcome%'

	UPDATE [dbo].ReportLookup SET ReportGroup = 'Cluster' WHERE ReportName like '%Cluster%'


RETURN 0
