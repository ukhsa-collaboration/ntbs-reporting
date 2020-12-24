CREATE VIEW [dbo].[vwEtsSpecimenMatch]
	AS   
	
   SELECT DISTINCT n.LegacyId, n.NotificationDate, a.ReferenceLaboratoryNumber, MAX(lr.AuditCreate) AS MostRecentMatchDate
   FROM [$(ETS)].[dbo].[LaboratoryResult] lr
	INNER JOIN [$(Labbase2)].[dbo].[Anonymised] a ON a.OpieId = lr.OpieId
	INNER JOIN [$(ETS)].[dbo].[Notification] n ON n.Id = lr.NotificationId

   WHERE lr.OpieId IS NOT NULL
	AND lr.AuditDelete IS NULL
	AND n.NotificationDate > '2010-01-01'
	AND n.Submitted = 1
	AND n.DenotificationId IS NULL
	GROUP BY n.LegacyId, n.NotificationDate, a.ReferenceLaboratoryNumber
