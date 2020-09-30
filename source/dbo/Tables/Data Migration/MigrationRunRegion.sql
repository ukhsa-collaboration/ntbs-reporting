CREATE TABLE [dbo].[MigrationRunRegion]
(
	[MigrationRunRegionId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[MigrationRunId] INT NOT NULL,
	[MigrationRunRegionName] NVARCHAR(50) NOT NULL, 
    CONSTRAINT [FK_MigrationRunRegion_ToMigrationRun] FOREIGN KEY ([MigrationRunId]) REFERENCES [MigrationRun]([MigrationRunId])
)
