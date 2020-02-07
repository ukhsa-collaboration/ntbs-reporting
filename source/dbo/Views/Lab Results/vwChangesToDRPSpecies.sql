CREATE VIEW [dbo].[vwChangesToDRPSpecies]
	AS 

	SELECT	 drp.[NotificationId]
			,drp.[Species] as 'Current Species'
			,drp.[DrugResistanceProfileString] as 'Current DrugResistanceProfile'
			,rn.Species as 'New Species'
			,rn.DrugResistanceProfile as 'New DrugResistanceProfile'
	FROM [$(NTBS)].[dbo].[DrugResistanceProfile] drp
			INNER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = drp.NotificationId
			--TODO: Update this to reusable notification when NTBS-804 is implemented
			LEFT OUTER JOIN [dbo].[CultureAndResistanceSummary] rn ON rn.NotificationId = drp.NotificationId
	WHERE	n.NotificationStatus NOT IN ('Draft', 'Deleted')
			AND (((drp.Species != rn.Species) OR (drp.Species IS NULL AND rn.Species IS NOT NULL))
			OR ((drp.DrugResistanceProfileString != rn.DrugResistanceProfile) OR (drp.DrugResistanceProfileString IS NULL AND rn.DrugResistanceProfile IS NOT NULL)))

