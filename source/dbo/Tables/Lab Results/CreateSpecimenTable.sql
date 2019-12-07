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