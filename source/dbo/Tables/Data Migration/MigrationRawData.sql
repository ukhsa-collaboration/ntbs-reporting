CREATE TABLE [dbo].[MigrationRawData]
(
	[MigrationRunId] INT NOT NULL,
	[JobNumber] [nvarchar](100)  NULL,
	[JobCode] [nvarchar](100)  NULL,
	[Score] [float] NOT NULL,
	[ExpireAt] [datetime] NULL,
	[RowDetails] [nvarchar](256) NOT NULL, 
    [NotificationId] NVARCHAR(30) NULL, 
    [Category] NVARCHAR(20) NULL, 
    [Reason] NVARCHAR(150) NULL, 
    [ChangeIndicator] INT NULL, 
    [RowGroup] INT NULL
) ON [PRIMARY]
