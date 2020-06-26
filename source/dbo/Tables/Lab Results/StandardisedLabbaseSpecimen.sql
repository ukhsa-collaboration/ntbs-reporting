CREATE TABLE [dbo].[StandardisedLabbaseSpecimen]
(
	[ReferenceLaboratoryNumber] [nvarchar](50) NULL,
	[SpecimenDate] [datetime] NULL,
	[LabDataID] [uniqueidentifier] NULL,
	[OpieId] [nvarchar](36) NULL,
	[IdentityColumn] [int] NULL,
	[SpecimenTypeCode] [nvarchar](255) NULL,
	[AuditCreate] [datetime] NULL,
	[OrganismName] [nvarchar](65) NULL
)

GO

CREATE INDEX [IX_LabbaseSpecimen_ReferenceLaboratoryNumber] ON [dbo].[StandardisedLabbaseSpecimen] ([ReferenceLaboratoryNumber])
