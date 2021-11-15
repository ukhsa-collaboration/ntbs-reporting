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
	[LegacyOutcomeId] [int] NULL,
	[EtsTreatmentOutcome] [varchar] (50) NULL,
	[ProxyTestDateUsed] [varchar](3) NULL,
	[NTBSNotificationId] [int] NULL,
	[NTBSHospitalName] [nvarchar](200)  NULL,
	[NTBSCaseManagerUsername] [nvarchar](150) NULL,
	[TBServiceName] [nvarchar](200)  NULL,
	[NTBSRegion] [nvarchar](50)  NULL,
	[NTBSOutcomeId] [int] NULL,
	[NTBSTreatmentOutcome] [varchar](30) NULL,
	[MigrationResult] [nvarchar](20)  NULL,
	[MigrationAlerts] [nvarchar](1000)  NULL,
	[MigrationNotes] [nvarchar](MAX)  NULL
) ON [PRIMARY]

