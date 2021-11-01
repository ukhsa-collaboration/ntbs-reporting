/*
	This view finds the specimens which have been matched to more than ETS notification. This typically happens when:
	- a person has TB twice and so is notified twice, some years apart
	- a single infection of TB is notified by two people, creating a duplicate notification record
*/

CREATE VIEW [dbo].[vwEtsDuplicateMatches]
	AS 
  WITH EtsNotificationSpecimenMatch AS
  (SELECT DISTINCT n.LegacyId, a.ReferenceLaboratoryNumber, n.NotificationDate
   FROM [$(OtherServer)].[$(ETS)].[dbo].[LaboratoryResult] lr
	INNER JOIN [$(Labbase2)].[dbo].[Anonymised] a ON a.OpieId = lr.OpieId
	INNER JOIN [$(OtherServer)].[$(ETS)].[dbo].[Notification] n ON n.Id = lr.NotificationId
   WHERE lr.OpieId IS NOT NULL
	AND lr.AuditDelete IS NULL
	AND n.NotificationDate > '2010-01-01'
	AND n.Submitted = 1
	AND n.DenotificationId IS NULL),

  DuplicateNotifications AS
  (SELECT e.ReferenceLaboratoryNumber, COUNT(e.LegacyId) AS CountOfNotifs
	FROM EtsNotificationSpecimenMatch e
	GROUP BY e.ReferenceLaboratoryNumber
	HAVING COUNT (e.LegacyId) > 1)

  SELECT e.LegacyId, e.NotificationDate, e.ReferenceLaboratoryNumber
  FROM
  EtsNotificationSpecimenMatch e
	INNER JOIN DuplicateNotifications d ON d.ReferenceLaboratoryNumber = e.ReferenceLaboratoryNumber
