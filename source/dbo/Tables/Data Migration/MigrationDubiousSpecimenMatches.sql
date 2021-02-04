CREATE TABLE [dbo].[MigrationDubiousSpecimenMatches]
(
	EtsId [bigint] NOT NULL,
	ReferenceLaboratoryNumber VARCHAR(50) NOT NULL,
	SpecimenDateRangeFlag bit null,
	NHSNumberDifferentFlag bit null, 
	SpecimenMultipleNotificationMatchFlag bit null,
	DenotifiedMatchFlag bit null,
	DeletedDraftFlag bit null
)
