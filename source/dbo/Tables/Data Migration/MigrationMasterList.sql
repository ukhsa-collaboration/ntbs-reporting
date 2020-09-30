CREATE TABLE [dbo].[MigrationMasterList]
(
	[OldNotificationId] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[OldHospitalId] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[OldHospitalName] [nvarchar](255) COLLATE Latin1_General_CI_AS NULL,
	[NtbsHospitalId] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[EtsID] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[LtbrId] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[GroupId] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[NotificationDate] [datetime] NOT NULL,
	[Denotified] [nvarchar](3) NOT NULL,
	[DenotificationDate] [datetime] NULL,
	[SourceSystem] [nvarchar](10) NULL,
	[Region] [varchar](50) COLLATE Latin1_General_CI_AS NULL,
	[LinkedNotifications] [varchar](8000) COLLATE Latin1_General_CI_AS NULL, 
    [NotificationYear] INT NULL
) ON [PRIMARY]

GO

CREATE INDEX [IX_MigrationMasterList_OldNotificationId] ON [dbo].[MigrationMasterList] (OldNotificationId)
