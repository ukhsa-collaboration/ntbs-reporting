/*This creates a consolidated view of all susceptibility results that are associated with the in-scope (i.e. TB)
specimens.  It calculates standard drug codes and results, and exposes an 'isWGS' flag*.
For use in reporting, it also calculates a 'received date', which is based on either the received date or the create date
in Anonymised, if the former is not populated*/

CREATE VIEW [dbo].[vwSusceptibilityResultDetail]
	AS 
	
		SELECT DISTINCT 
			vs.ReferenceLaboratoryNumber,
			CASE
				WHEN a.ReceivedDate IS NULL THEN a.AuditCreate
				ELSE a.ReceivedDate
			END as 'ReceivedDate',
			am.AntibioticOutputName, 
			am.IsWGS, 
			rm.ResultOutputName, 
			rm.[Rank] 
		FROM vwSpecimen vs
			INNER JOIN LabSpecimen ls ON ls.ReferenceLaboratoryNumber = vs.ReferenceLaboratoryNumber
			INNER JOIN [$(Labbase2)].dbo.Anonymised a on vs.IdentityColumn = a.IdentityColumn
			INNER JOIN [$(Labbase2)].dbo.Susceptibility su ON su.LabDataID = vs.LabDataID
			LEFT OUTER JOIN [dbo].[AntibioticMapping] am  ON am.AntibioticCode = su.AntibioticCode
			LEFT OUTER JOIN [dbo].[ResultMapping] rm  ON rm.Result = su.SusceptibilityResult