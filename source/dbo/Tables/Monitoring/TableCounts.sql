CREATE TABLE [dbo].[TableCounts]
(
	[CountTime] DATETIME2 NOT NULL PRIMARY KEY,
	[MigrationNotificationsViewCount] INT NOT NULL,
	[MigrationMBovisAnimalExposureViewCount] INT NOT NULL,
	[MigrationMBovisExposureToKnownCaseViewCount] INT NOT NULL,
	[MigrationMBovisOccupationExposuresViewCount] INT NOT NULL,
	[MigrationMBovisUnpasteurisedMilkConsumptionViewCount] INT NOT NULL,
	[MigrationSocialContextAddressViewCount] INT NOT NULL,
	[MigrationSocialContextVenueViewCount] INT NOT NULL,
	[TransfersViewCount] INT NOT NULL,
	[TreatmentOutcomesCount] INT NOT NULL,
	[EtsNotificationsCount] INT NOT NULL,
	[LtbrNotificationsCount] INT NOT NULL,
	[ETS_NotificationCount] INT NOT NULL,
	[LTBR_DiseasePeriodCount] INT NOT NULL,
	[LTBR_PatientEpisodeCount] INT NOT NULL,
	[NotificationClusterMatchCount] INT NOT NULL,
	[NotificationSpecimenMatchCount] INT NOT NULL,
	[EtsSpecimenMatchCount] INT NOT NULL
)
