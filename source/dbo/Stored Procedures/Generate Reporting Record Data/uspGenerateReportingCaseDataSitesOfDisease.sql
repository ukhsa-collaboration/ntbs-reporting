CREATE PROCEDURE [dbo].[uspGenerateReportingCaseDataSitesOfDisease]
AS
BEGIN TRY
	--get the list of all site output names
	WITH cteDiseaseSites(SiteOutputName) AS
	(SELECT [Description] FROM
	[$(NTBS)].ReferenceData.[Site]),

	--get the list of notifications from companion table
	cteNotification(NotificationId) AS
	(SELECT NotificationId
	FROM [dbo].[RecordRegister]
	WHERE SourceSystem = 'NTBS'),

	--then one row per site for the notification.
		cteNotificationSites (NotificationId, SiteOutputName, HasSite) AS
		(SELECT ns.NotificationId, refs.[Description], 'Yes' AS 'HasSite'
		FROM [$(NTBS)].[dbo].[NotificationSite] ns
		INNER JOIN cteNotification ce ON ce.NotificationId = ns.NotificationId
		LEFT OUTER JOIN [$(NTBS)].ReferenceData.[Site] refs ON refs.SiteId = ns.SiteId
		GROUP BY ns.NotificationId, refs.[Description]),

	--then cross-join so there is one per notification and site of disease, inserting a zero if the notification does not have that site of disease
	--also map to output names

	cteAllResults(NotificationId, SiteOutputName, HasSite) AS
	(SELECT DISTINCT n.NotificationId, cd.SiteOutputName, COALESCE(c.HasSite, 'No') AS HasSite
		FROM cteNotification n
		CROSS JOIN cteDiseaseSites cd
		LEFT OUTER JOIN cteNotificationSites c
			ON c.NotificationId = n.NotificationId AND c.SiteOutputName = cd.SiteOutputName),

	--then create a pivot table of the values so there is one row per notificationId
	ctePivotResults(NotificationId, [Pulmonary site], [Spine site], [Bone/joint: Other site], [Meningitis site], [CNS: Other site],
			[Ocular site], [Cryptic disseminated site], [Gastrointestinal/peritoneal site], [Genitourinary site],
			[Lymph nodes: Intra-thoracic site], [Lymph nodes: Extra-thoracic site], [Laryngeal site],
			[Miliary site], [Pleural site], [Pericardial site], [Soft tissue/Skin site], [Other extra-pulmonary site]) AS
	(SELECT * FROM cteAllResults
		AS SOURCE
		PIVOT
		(
			MAX(HasSite)
			FOR [SiteOutputName] IN ([Pulmonary], [Spine], [Bone/joint: Other], [Meningitis], [CNS: Other],
			[Ocular], [Cryptic disseminated], [Gastrointestinal/peritoneal], [Genitourinary],
			[Lymph nodes: Intra-thoracic], [Lymph nodes: Extra-thoracic], [Laryngeal],
			[Miliary], [Pleural], [Pericardial], [Soft tissue/Skin], [Other extra-pulmonary])
		) AS Result)

	--finally perform the update
	UPDATE cd
		SET [Pulmonary site] = pr.[Pulmonary site],
		[Spine site] = pr.[Spine site],
		[Bone/joint: Other site] = pr.[Bone/joint: Other site],
		[Meningitis site] = pr.[Meningitis site],
		[CNS: Other site] = pr.[CNS: Other site],
		[Ocular site] = pr.[Ocular site],
		[Cryptic disseminated site] = pr.[Cryptic disseminated site],
		[Gastrointestinal/peritoneal site] = pr.[Gastrointestinal/peritoneal site],
		[Genitourinary site] = pr.[Genitourinary site],
		[Lymph nodes: Intra-thoracic site] = pr.[Lymph nodes: Intra-thoracic site],
		[Lymph nodes: Extra-thoracic site] = pr.[Lymph nodes: Extra-thoracic site],
		[Laryngeal site] = pr.[Laryngeal site],
		[Miliary site] = pr.[Miliary site],
		[Pleural site] = pr.[Pleural site],
		[Pericardial site] = pr.[Pericardial site],
		[Soft tissue/Skin site] = pr.[Soft tissue/Skin site],
		[Other extra-pulmonary site] = pr.[Other extra-pulmonary site]
		FROM [dbo].[Record_CaseData] cd
			INNER JOIN ctePivotResults pr ON pr.NotificationId = cd.NotificationId

	--Add in the OtherExtraPulmonarySite text
	UPDATE cd
		SET [Other extra-pulmonary site description] = ns.SiteDescription
	FROM [dbo].[Record_CaseData] cd
		INNER JOIN [$(NTBS)].[dbo].[NotificationSite] ns ON ns.NotificationId = cd.NotificationId
	WHERE ns.SiteId = 17 -- Other extra-pulmonary

END TRY
BEGIN CATCH
	THROW
END CATCH
