CREATE TABLE [dbo].[MigrationRunResults]
(
	[MigrationRunResultsId] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[MigrationRunId] [int] NOT NULL,
	[MigrationNotificationId] [NVARCHAR](30) NOT NULL,
	[LegacyRegion] [varchar](50) NULL,
	[LegacyETSId] [varchar](50) NULL,
	[LegacyLtbrNo] [varchar](50)  NULL,
	[NotificationDate] [datetime] NULL,
	[GroupId] [varchar](50)  NULL,
	[SourceSystem] [nvarchar](10)  NULL,
	[LegacyHospitalId] [varchar](50)  NULL,
	[LegacyHospitalName] [nvarchar](255)  NULL,
	[EtsTreatmentOutcome] [varchar] (30) NULL,
	[ProxyTestDateUsed] [varchar](3) NULL,
	[NTBSNotificationId] [int] NULL,
	[NTBSHospitalName] [nvarchar](200)  NULL,
	[TBServiceName] [nvarchar](200)  NULL,
	[NTBSRegion] [nvarchar](50)  NULL,
	[NTBSTreatmentOutcome] [varchar](30) NULL,
	[MigrationResult] [nvarchar](20)  NULL,
	[MigrationNotes] [nvarchar](4000)  NULL
) ON [PRIMARY]

