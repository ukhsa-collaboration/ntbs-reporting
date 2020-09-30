CREATE TABLE [dbo].[MigrationRawData]
(
	[MigrationRunId] INT NOT NULL,
	[JobNumber] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[JobCode] [nvarchar](100) COLLATE Latin1_General_CI_AS NULL,
	[Score] [float] NOT NULL,
	[ExpireAt] [datetime] NULL,
	[RowDetails] [nvarchar](256) COLLATE Latin1_General_CI_AS NOT NULL, 
    [NotificationId] NVARCHAR(30) NULL, 
    [Category] NVARCHAR(20) NULL, 
    [Reason] NVARCHAR(150) NULL, 
    [ChangeIndicator] INT NULL, 
    [RowGroup] INT NULL
) ON [PRIMARY]
