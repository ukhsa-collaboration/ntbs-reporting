CREATE TABLE [dbo].[StandardisedLabbaseSusceptibilityResult]
(
	[ReferenceLaboratoryNumber] [nvarchar](50) NULL,
	[AntibioticOutputName] [nvarchar](50) NULL,
	[IsWGS] [bit] NULL,
	[ResultOutputName] [nvarchar](50) NULL,
	[Rank] [int] NULL
)

GO

CREATE INDEX [IX_LabBaseSusceptibilityResult_ReferenceLaboratoryNumber] ON [dbo].[StandardisedLabbaseSusceptibilityResult] ([ReferenceLaboratoryNumber])
