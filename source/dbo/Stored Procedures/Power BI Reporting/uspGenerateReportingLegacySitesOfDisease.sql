CREATE PROCEDURE [dbo].[uspGenerateReportingLegacySitesOfDisease]
AS
BEGIN TRY
	--get the list of all legacy site outputnames
	WITH cteLegacyDiseaseSites(SiteOutputName) AS
	(SELECT SiteOutputName FROM
	[dbo].[LegacySiteMapping]),

	--get the list of notifications from companion table
	cteNotification(NotificationId) AS
	(SELECT NotificationId
	FROM [dbo].[RecordRegister]
	WHERE SourceSystem = 'NTBS'),

	--then one row per legacy site for the notification. This will group
	--some sites together under 'NonPulmonaryOther'
		cteNotificationSites (NotificationId, SiteOutputName, HasSite) AS
		(SELECT ns.NotificationId, ls.SiteOutputName, 'TRUE' AS 'HasSite'
		FROM [$(NTBS)].[dbo].[NotificationSite] ns
		INNER JOIN cteNotification ce ON ce.NotificationId = ns.NotificationId
		LEFT OUTER JOIN [dbo].[LegacySiteMapping] ls ON ls.SiteId = ns.SiteId
		GROUP BY ns.NotificationId, ls.SiteOutputName),

	--then cross-join so there is one per notification and site of disease, inserting a zero if the notification does not have that site of disease
	--also map to output names

	cteAllResults(NotificationId, SiteOutputName, HasSite) AS
	(SELECT DISTINCT n.NotificationId, cd.SiteOutputName, COALESCE(c.HasSite, 'FALSE') AS HasSite
		FROM cteNotification n
		CROSS JOIN cteLegacyDiseaseSites cd
		LEFT OUTER JOIN cteNotificationSites c
			ON c.NotificationId = n.NotificationId AND c.SiteOutputName = cd.SiteOutputName),

	--then create a pivot table of the values so there is one row per notificationId
	ctePivotResults(NotificationId, [SitePulmonary], [SiteBoneSpine], [SiteBoneOther], [SiteCNSMeningitis], [SiteCNSOther], [SiteCryptic], [SiteGI], [SiteGU], [SiteITLymphNodes],
				[SiteLymphNode], [SiteLaryngeal], [SiteMiliary], [SitePleural], [SiteNonPulmonaryOther]) AS
	(SELECT * FROM cteAllResults
		AS SOURCE
		PIVOT
		(
			MAX(HasSite)
			FOR [SiteOutputName] IN ([SitePulmonary], [SiteBoneSpine], [SiteBoneOther], [SiteCNSMeningitis], [SiteCNSOther], [SiteCryptic], [SiteGI], [SiteGU], [SiteITLymphNodes],
				[SiteLymphNode], [SiteLaryngeal], [SiteMiliary], [SitePleural], [SiteNonPulmonaryOther])
		) AS Result)

	--finally perform the update
	UPDATE le
		SET SitePulmonary = pr.SitePulmonary,
		SiteBoneSpine = pr.SiteBoneSpine,
		SiteBoneOther = pr.SiteBoneOther,
		SiteCNSMeningitis = pr.SiteCNSMeningitis,
		SiteCNSOther = pr.SiteCNSOther,
		SiteCryptic = pr.SiteCryptic,
		SiteGI = pr.SiteGI,
		SiteGU = pr.SiteGU,
		SiteITLymphNodes = pr.SiteITLymphNodes,
		SiteLymphNode = pr.SiteLymphNode,
		SiteLaryngeal = pr.SiteLaryngeal,
		SiteMiliary = pr.SiteMiliary,
		SitePleural = pr.SitePleural,
		SiteNonPulmonaryOther = pr.SiteNonPulmonaryOther,
		SiteNonPulmonaryUnknown = 'FALSE',
		SiteUnknown = 'FALSE'
		FROM [dbo].[Record_LegacyExtract] le
			INNER JOIN ctePivotResults pr ON pr.NotificationId = le.NotificationId

	--Add in the OtherExtraPulmonarySite text
	UPDATE le
		SET OtherExtraPulmonarySite = ns.SiteDescription
	FROM [dbo].[Record_LegacyExtract] le
		INNER JOIN [$(NTBS)].[dbo].[NotificationSite] ns ON ns.NotificationId = le.NotificationId
	WHERE ns.SiteId = 17 -- Other extra-pulmonary

END TRY
BEGIN CATCH
	THROW
END CATCH
