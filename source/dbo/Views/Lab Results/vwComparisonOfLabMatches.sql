CREATE VIEW [dbo].[vwComparisonOfLabMatches]
	AS


	--we basically want a list of every ref lab number with at least one match to start off with

	WITH AllMatchedSpecimens AS
	(
		SELECT ReferenceLaboratoryNumber from [$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch]
		UNION
		SELECT ReferenceLaboratoryNumber from [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch]
		WHERE MatchType = 'Confirmed'),

	--then eliminate the migrated matches
	AllMatchedMinusMigrated AS
	(
		SELECT ReferenceLaboratoryNumber FROM AllMatchedSpecimens
		EXCEPT
		SELECT ReferenceLaboratoryNumber FROM  [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch] WHERE MatchMethod = 'Migration'
	)

	SELECT		am.ReferenceLaboratoryNumber
				,esm.LegacyId AS 'ETS Match - ETS ID'
				,n1.NotificationId AS 'ETS Match - corresponding NTBS ID'
				,nsm.NotificationID AS 'NTBS Match - NTBS ID'
				,n2.ETSID AS 'NTBS Match - corresponding ETS ID'
				--find the later match date - this is used to decide if this is a new match (last 3 days)
				,CASE WHEN COALESCE(esm.EarliestMatchDate, '') > COALESCE(nsm.UpdateDateTime, '') THEN esm.EarliestMatchDate ELSE nsm.UpdateDateTime END AS 'MatchDate'
				--now calculate the scenario of each match
				,CASE
					--1. matched to same record in ETS and NTBS
					WHEN esm.LegacyId IS NOT NULL AND n2.ETSID IS NOT NULL AND esm.LegacyId = n2.ETSID AND n1.NotificationId IS NOT NULL AND nsm.NotificationID IS NOT NULL AND n1.NotificationId = nsm.NotificationID THEN 1
					--2. matched to record only in ETS
					WHEN esm.LegacyId IS NOT NULL AND n1.NotificationId IS NULL AND nsm.NotificationID IS NULL THEN 2
					--3. matched to record only NTBS
					WHEN esm.LegacyId IS NULL AND n1.NotificationId IS NULL AND nsm.NotificationID IS NOT NULL AND n2.ETSID IS NULL THEN 3
					--4. matching to two completely separate records in ETS and NTBS (implication being neither are migrated records - arguably this could also cover the case where both are migrated but not the same - this is currently covered in 7
					WHEN esm.LegacyId IS NOT NULL AND nsm.NotificationID IS NOT NULL AND n1.NotificationId IS NULL AND n2.ETSID IS NULL THEN 4
					--5. match to NTBS half of a migrated record only
					WHEN esm.LegacyId IS NULL AND nsm.NotificationID IS NOT NULL AND n2.ETSID IS NOT NULL THEN 5
					--6. match to ETS half of a migrated record only
					WHEN esm.LegacyId IS NOT NULL AND n1.NotificationId IS NOT NULL AND nsm.NotificationID IS NULL THEN 6
					--7. match to NTBS half of a migrated record + different ETS record
					WHEN esm.LegacyId IS NOT NULL AND nsm.NotificationID IS NOT NULL AND n2.ETSID IS NOT NULL AND n2.ETSID != esm.LegacyId THEN 7
					--8. match to ETS half of a migrated record + different NTBS record
					WHEN esm.LegacyId IS NOT NULL AND n1.NotificationId IS NOT NULL AND nsm.NotificationID IS NOT NULL AND nsm.NotificationID != n1.NotificationId THEN 8
					ELSE 0
					END
				AS Scenario
	FROM AllMatchedMinusMigrated am
		LEFT OUTER JOIN [$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch] esm ON esm.ReferenceLaboratoryNumber = am.ReferenceLaboratoryNumber
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Notification] n1 ON n1.ETSID = esm.LegacyId
		LEFT OUTER JOIN [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch] nsm ON nsm.ReferenceLaboratoryNumber = am.ReferenceLaboratoryNumber AND MatchType = 'Confirmed' and MatchMethod != 'Migration'
		LEFT OUTER JOIN [$(NTBS)].[dbo].[Notification] n2 ON n2.NotificationId = nsm.NotificationID
