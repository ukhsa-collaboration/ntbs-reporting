--this can be used to set up the ReportingFeatureFlags table in your chosen environment - set the values 
--according to what you need.  It assumes the table is currently empty

IF (SELECT COUNT(1) FROM [dbo].[ReportingFeatureFlags]) = 0
BEGIN
	INSERT INTO [dbo].[ReportingFeatureFlags](IncludeNTBS, IncludeETS, IncludeLabBase, Comment)
	VALUES(0, 0, 0, 'Include or exclude records from various datasources in the reporting database')
END