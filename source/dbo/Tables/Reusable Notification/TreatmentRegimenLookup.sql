CREATE TABLE [dbo].[TreatmentRegimenLookup]
(
	[Id] INT IDENTITY(1,1) NOT NULL,
	[TreatmentRegimenCode] NVARCHAR(30) NOT NULL,
	[TreatmentRegimenDescription] NVARCHAR(30) NOT NULL,
	CONSTRAINT [PK_TreatmentRegimenLookup] PRIMARY KEY ([Id])
)
