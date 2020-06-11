/*We need to exclude entries in the LaboratoryResult table where the AuditDelete field has a value, as these have been
logically deleted, for example, manually unmatched reference lab result*/

CREATE VIEW [dbo].[vwETSLaboratoryResult]
	AS 
	SELECT n.LegacyId AS NotificationId
		,lr.Id
		,lr.LaboratoryCategoryId
		,lr.SpecimenTypeId
		,lr.Result
		,lr.MycobacterialSpeciesId
		,lr.StatusSet
		,lr.Received
		,lr.OpieId
		,lr.LaboratoryId
		,lr.AuditUserId
		,lr.AuditCreate
		,lr.AuditDelete
		,lr.AuditAlter
		,lr.AutoMatched
	FROM [$(ETS)].[dbo].[LaboratoryResult] lr
	LEFT JOIN [$(ETS)].dbo.[Notification] n ON n.Id = lr.NotificationId
		WHERE lr.AuditDelete IS NULL
