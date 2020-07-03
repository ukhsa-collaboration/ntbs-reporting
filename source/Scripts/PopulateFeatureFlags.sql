--this can be used to set up the ReportingFeatureFlags table in your chosen environment - set the values 
--according to what you need.  It assumes the table is currently empty

IF (SELECT COUNT(1) FROM [dbo].[ReportingFeatureFlags]) = 0
BEGIN
	INSERT INTO [dbo].[ReportingFeatureFlags](IncludeNTBS, SourceUsersFromNTBS, Comment)
	VALUES(0, 0, 'The first flag ensures records are not sourced from NTBS if it is not active. The second flag allows users to be sourced via
	the NTBS user sync process once that is active, even if the application itself is not yet in use')
END