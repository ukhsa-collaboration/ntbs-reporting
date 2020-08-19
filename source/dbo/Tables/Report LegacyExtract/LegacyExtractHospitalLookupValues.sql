CREATE TABLE [dbo].[LegacyExtractHospitalLookupValues]
(
	[Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[HospitalId] [nvarchar](36) NULL,
	[HospitalName] [nvarchar](255) NULL,
	[TreatmentHPU] [nvarchar](255) NULL
)
