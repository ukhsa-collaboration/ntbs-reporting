CREATE VIEW [dbo].[vwEtsSpecimenMatch]
	AS   
	
	SELECT DISTINCT 
		n.LegacyId 
		,s.ReferenceLaboratoryNumber 
		,MIN(lr.auditcreate) OVER (PARTITION BY n.LegacyID) AS EarliestMatchDate
		,MIN(s.SpecimenDate) OVER (PARTITION BY s.ReferenceLaboratoryNumber) AS SpecimenDate 
		,CASE WHEN n.DenotificationId IS NOT NULL THEN 1 ELSE 0 END AS Denotified
		,CASE WHEN n.Submitted = 0 THEN 1 ELSE 0 END AS Draft
		,MAX(CASE WHEN lr.AutoMatched = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY s.ReferenceLaboratoryNumber) AS Automatched
	FROM [$(ETS)].[dbo].[Notification] n
	INNER JOIN [$(ETS)].[dbo].[LaboratoryResult] lr ON lr.NotificationId = n.Id
	INNER JOIN [StandardisedLabbaseSpecimen] s ON s.OpieId = lr.OpieId
	WHERE 
	   n.[AuditDelete] IS NULL
	   --include denotified and draft records in this query, so these can be highlighted as bad matches, so unlike most similar queries we do not include
	    --n.DenotificationId IS NULL AND n.Submitted = 1
		AND lr.OpieId IS NOT NULL
		AND lr.AuditDelete IS NULL
