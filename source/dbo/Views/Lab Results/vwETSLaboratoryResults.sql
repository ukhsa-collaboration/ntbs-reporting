/*We need to exclude entries in the LaboratoryResult table where the AuditDelete field has a value, as these have been
logically deleted, for example, manually unmatched reference lab result*/

CREATE VIEW [dbo].[vwETSLaboratoryResult]
	AS SELECT * FROM [$(ETS)].[dbo].[LaboratoryResult] lr
		WHERE lr.AuditDelete IS NOT NULL
