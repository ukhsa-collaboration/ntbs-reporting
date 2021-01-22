CREATE TABLE [dbo].[LabSpecimen](
	[LabSpecimenId] [int] IDENTITY(1,1) NOT NULL,
	[ReferenceLaboratoryNumber] [nvarchar](50) NOT NULL,
	[SpecimenDate] [datetime] NULL,
	[EarliestRecordDate] [datetime] NULL,
	[SpecimenTypeCode] [nvarchar](255) NULL,
	[LaboratoryName] [nvarchar](65) NULL,
	[ReferenceLaboratory] [nvarchar](65) NULL,
	[Species] [varchar](50) NULL,
	[INH][nvarchar](25) NULL,
	[RIF][nvarchar](25) NULL,
	[PZA][nvarchar](25) NULL,
	[EMB][nvarchar](25) NULL,
	[MDR][nvarchar](10) NULL,
	[AMINO][nvarchar](25) NULL,
	[QUIN][nvarchar](25) NULL,
	[XDR][nvarchar](10) NULL,
	[PatientNhsNumber] [nvarchar](12) NULL,
	[PatientBirthDate] [datetime] NULL,
	[PatientName] [nvarchar](150) NULL,
	[PatientGivenName] NVARCHAR(75) NULL, 
    [PatientFamilyName] NVARCHAR(75) NULL, 
	[PatientSex] [nvarchar](1) NULL,
	[PatientAddress] [nvarchar](255) NULL,
	[PatientPostcode] [nvarchar](10) NULL,
 
    CONSTRAINT [PK_LabSpecimenId] PRIMARY KEY CLUSTERED 
(
	[LabSpecimenId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO



/****** Object:  Index [IX_LabSpecimen_ReferenceLaboratoryNumber]    Script Date: 11/12/2019 10:20:07 ******/
CREATE NONCLUSTERED INDEX [IX_LabSpecimen_ReferenceLaboratoryNumber] ON [dbo].[LabSpecimen]
(
	[ReferenceLaboratoryNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO


/*
/****** Object:  Index [IX_NotificationSpecimenMatch_ReferenceLaboratoryNumber]    Script Date: 11/12/2019 10:20:07 ******/
CREATE NONCLUSTERED INDEX [IX_NotificationSpecimenMatch_ReferenceLaboratoryNumber] ON [dbo].[LabSpecimen]
(
	[ReferenceLaboratoryNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO



/****** Object:  Index [IX_UnmatchedSpecimen_ReferenceLaboratoryNumber]    Script Date: 11/12/2019 10:20:07 ******/
CREATE NONCLUSTERED INDEX [IX_UnmatchedSpecimen_ReferenceLaboratoryNumber] ON [dbo].[LabSpecimen]
(
	[ReferenceLaboratoryNumber] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO

*/

/*CREATE TABLE [NTBS_Reporting_Staging].[dbo].[LabSpecimen]
(
	-- This primary key
	[LabSpecimenId] [int] IDENTITY(1,1) NOT NULL,
	-- LabBase primary key
	[ReferenceLaboratoryNumber] [nvarchar](50) NOT NULL,
	--TODO: CONSIDER RECORDS EARLIER THAN 2014 - DO THESE NOT HAVE A REFLABNO?
	[SpecimenDate] [datetime] NULL,
	[SpecimenTypeCode] [nvarchar](255) NULL,
	[LaboratoryName] [nvarchar](65) NULL,
	[ReferenceLaboratory] [nvarchar](65) NULL,
	[Species] [varchar](50) NULL,
	[PatientNhsNumber] [nvarchar](12) NULL,
	[PatientBirthDate] [datetime] NULL,
	[PatientName] [nvarchar](150) NULL,
	[PatientSex] [nvarchar](1) NULL,
	[PatientAddress] [nvarchar](255) NULL,
	[PatientPostcode] [nvarchar](10) NULL,

	CONSTRAINT [PK_LabSpecimenId] PRIMARY KEY CLUSTERED (
		[LabSpecimenId] ASC
	)
) 

ON [PRIMARY]
GO

--TODO cannot create due to lack of cross-database functionality
--CREATE NONCLUSTERED INDEX IX_LabSpecimen_ReferenceLaboratoryNumber ON dbo.LabSpecimen(ReferenceLaboratoryNumber)
--GO*/