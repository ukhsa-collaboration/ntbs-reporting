CREATE TABLE [dbo].[MigrationRun]
(
	[MigrationRunId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[MigrationRunName] NVARCHAR(100) NOT NULL,
	[MigrationRunDate] DATE NOT NULL, 
    [ImportedDate] DATE NULL,
	[LeadRegion] NVARCHAR(30) NULL,
	[HangfireStartJob] INT NULL,
	[HangfireEndJob] INT NULL, 
    [EtsDate] DATE NULL, 
    [LtbrDate] DATE NULL, 
    [LabbaseDate] DATE NULL, 
    [AppVersion] NVARCHAR(150) NULL
)
