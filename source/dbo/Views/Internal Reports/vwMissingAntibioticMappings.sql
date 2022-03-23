CREATE VIEW [dbo].[vwMissingAntibioticMappings]
AS

SELECT su.AntibioticCode,
	COUNT(DISTINCT a.ReferenceLaboratoryNumber) AS NumberOfSamples,
	MIN(a.AuditCreate) AS DateFirstIntroduced,
	MAX(a.AuditCreate) AS LastSeen
FROM [$(Labbase2)].dbo.Susceptibility su
	INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.LabDataID = su.LabDataID
WHERE su.AntibioticCode NOT IN (SELECT AntibioticCode FROM [$(NTBS_Specimen_Matching)].dbo.AntibioticMapping)
	-- Don't warn about not being able to map things that aren't antibiotics
	AND su.AntibioticCode NOT IN ('New', 'Gynaecological', 'Other tissues')
	AND a.IsAtypicalOrganismRecord = 0
	AND a.MergedRecord = 0
GROUP BY su.AntibioticCode
