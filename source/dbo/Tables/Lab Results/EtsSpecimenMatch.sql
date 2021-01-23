CREATE TABLE [dbo].[EtsSpecimenMatch](
	[LegacyId] [bigint] NOT NULL,
	[ReferenceLaboratoryNumber] [nvarchar](50) NOT NULL,
	[EarliestMatchDate] [datetime] NULL,
	[SpecimenDate] [datetime] NULL,
	[Denotified] [int] NULL,
	[Draft] [int] NULL,
	[Automatched] [int] NULL
) ON [PRIMARY]
GO
