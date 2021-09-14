CREATE TABLE [dbo].[MigrationRun]
(
	[MigrationRunId] INT PRIMARY KEY,
	[MigrationRunName] NVARCHAR(MAX) NOT NULL,
	[MigrationRunDate] DATE NOT NULL, 
    [ImportedDate] DATE NULL,
    [EtsDate] DATE NULL, 
    [LtbrDate] DATE NULL, 
    [LabbaseDate] DATE NULL, 
    [AppVersion] NVARCHAR(150) NULL,
    [MigrationVersion] NVARCHAR(150) NULL
)
