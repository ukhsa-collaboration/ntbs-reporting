CREATE TABLE [dbo].[MigrationRun]
(
	[MigrationRunId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[MigrationRunName] NVARCHAR(100) NOT NULL,
	[MigrationRunDate] DATE NOT NULL, 
    [ImportedDate] DATE NULL
)
