/*This creates a consolidated view of all susceptibility results that are associated with the in-scope (i.e. TB)
specimens.  It calculates standard drug codes and results, and exposes an 'isWGS' flag*/

CREATE VIEW [dbo].[vwSusceptibilityResult]
	AS 
	
		SELECT DISTINCT 
			vs.ReferenceLaboratoryNumber, 
			am.AntibioticOutputName, 
			am.IsWGS, 
			rm.ResultOutputName, 
			rm.[Rank] 
		FROM vwSpecimen vs
			INNER JOIN LabSpecimen ls ON ls.ReferenceLaboratoryNumber = vs.ReferenceLaboratoryNumber
			INNER JOIN [$(Labbase2)].dbo.Susceptibility su ON su.LabDataID = vs.LabDataID
			LEFT OUTER JOIN [dbo].[AntibioticMapping] am  ON am.AntibioticCode = su.AntibioticCode
			LEFT OUTER JOIN [dbo].[ResultMapping] rm  ON rm.Result = su.SusceptibilityResult

