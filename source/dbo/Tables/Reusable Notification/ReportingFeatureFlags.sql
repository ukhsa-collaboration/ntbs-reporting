CREATE TABLE [dbo].[ReportingFeatureFlags]
(
    --this table has some flags which allow us to control how the reporting service interacts with NTBS
    --there is no population script, as the values are environment-specific
	[Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY, 
    [IncludeNTBS] BIT NULL, 
    [SourceUsersFromNTBS] BIT NULL, 
    [Comment] NVARCHAR(MAX) NULL
)
