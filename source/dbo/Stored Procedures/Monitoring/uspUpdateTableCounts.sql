CREATE PROCEDURE [dbo].[uspUpdateTableCounts]
AS
	INSERT INTO [TableCounts] (CountTime
		,MigrationNotificationsViewCount
		,MigrationMBovisAnimalExposureViewCount
		,MigrationMBovisExposureToKnownCaseViewCount
		,MigrationMBovisOccupationExposuresViewCount
		,MigrationMBovisUnpasteurisedMilkConsumptionViewCount
		,MigrationSocialContextAddressViewCount
		,MigrationSocialContextVenueViewCount
		,TransfersViewCount
		,TreatmentOutcomesCount
		,EtsNotificationsCount
		,LtbrNotificationsCount
		,ETS_NotificationCount
		,LTBR_DiseasePeriodCount
		,LTBR_PatientEpisodeCount
		,NotificationClusterMatchCount
		,NotificationSpecimenMatchCount
		,EtsSpecimenMatchCount
	)

	SELECT
		GETUTCDATE() AS CountTime
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.MigrationNotificationsView
		) AS MigrationNotificationsViewCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.MigrationMBovisAnimalExposureView
		) AS MigrationMBovisAnimalExposureViewCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.MigrationMBovisExposureToKnownCaseView
		) AS MigrationMBovisExposureToKnownCaseViewCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.MigrationMBovisOccupationExposuresView
		) AS MigrationMBovisOccupationExposuresViewCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.MigrationMBovisUnpasteurisedMilkConsumptionView
		) AS MigrationMBovisUnpasteurisedMilkConsumptionViewCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.MigrationSocialContextAddressView
		) AS MigrationSocialContextAddressViewCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.MigrationSocialContextVenueView
		) AS MigrationSocialContextVenueViewCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.TransfersView
		) AS TransfersViewCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.TreatmentOutcomes
		) AS TreatmentOutcomesCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.EtsNotifications
		) AS EtsNotificationsCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.LtbrNotifications
		) AS LtbrNotificationsCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.ETS_Notification
		) AS ETS_NotificationCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.LTBR_DiseasePeriod
		) AS LTBR_DiseasePeriodCount
		,(SELECT COUNT(*)
			FROM [$(migration)].dbo.LTBR_PatientEpisode
		) AS LTBR_PatientEpisodeCount
		,(SELECT COUNT(*)
			FROM [$(NTBS_Specimen_Matching)].dbo.NotificationClusterMatch
		) AS NotificationClusterMatchCount
		,(SELECT COUNT(*)
			FROM [$(NTBS_Specimen_Matching)].dbo.NotificationSpecimenMatch
		) AS NotificationSpecimenMatchCount
		,(SELECT COUNT(*)
			FROM [$(NTBS_Specimen_Matching)].dbo.EtsSpecimenMatch
		) AS EtsSpecimenMatchCount

RETURN 0
