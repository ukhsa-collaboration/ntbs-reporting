CREATE TABLE [NTBS_Reporting_Staging].[dbo].[TemporaryLabSpecimen]
(
	-- This primary key
	[TempLabSpecimenId] [int] IDENTITY(1,1) NOT NULL,
	-- LabBase primary key
	[ReferenceLaboratoryNumber] [nvarchar](50) NOT NULL,
	[SpecimenDate] [datetime] NULL,
	[SpecimenType] [nvarchar](255) NULL,
	[RequestingLaboratoryName] [nvarchar](65) NULL,
	[ReferenceLaboratory] [nvarchar](65) NULL,
	[Species] [varchar](50) NULL,
	[LabPatientNhsNumber] [nvarchar](12) NULL,
	[LabPatientBirthDate] [datetime] NULL,
	[LabPatientName] [nvarchar](150) NULL,
	[LabPatientSex] [nvarchar](1) NULL,
	[LabPatientAddress] [nvarchar](255) NULL,
	[LabPatientPostcode] [nvarchar](10) NULL,
	[NTBSID] [int] NULL,
	[TB_Service][nvarchar](16),
	[MatchType] [nvarchar](20) NULL,
	[CreationDateTime][datetime] NULL,
	[UpdateDateTime][datetime] NULL,
	[ConfidenceLevel][decimal](3,2) NULL,
	[NotificationDate][datetime] NULL,
	[NotificationName][nvarchar](30) NULL,
	[NotificationNhsNumber][nvarchar](12) NULL,
	[NotificationDateofBirth][datetime] NULL,
	[NotificationPostcode][nvarchar](12) NULL,
	[NotificationSex][int] NULL
 

	CONSTRAINT [PK_TempLabSpecimenId] PRIMARY KEY CLUSTERED (
		[TempLabSpecimenId] ASC
	)
) 

ON [PRIMARY]
GO
