CREATE VIEW [dbo].[vwNewAntibioticCodes]
AS

SELECT
	su.LabAntibiotic,
	a.ReferenceLaboratory,
	COUNT(DISTINCT a.ReferenceLaboratoryNumber) AS NumberOfSamples,
	MIN(a.AuditCreate) AS FirstIntroduced,
	MAX(a.AuditCreate) AS LastSeen
FROM [$(Labbase2)].dbo.Susceptibility su
	INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.LabDataID = su.LabDataID
WHERE su.AntibioticCode = 'New'
	AND a.IsAtypicalOrganismRecord = 0
	AND a.MergedRecord = 0
GROUP BY su.LabAntibiotic, a.ReferenceLaboratory
