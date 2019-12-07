/*USE [NTBS_Reporting_Staging]
GO

/****** Object:  View [dbo].[vwSpecies]    Script Date: 04/12/2019 08:08:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

/***************************************************************************************************
Desc:    This returns a list of specimens with a standardised RefLabNumber column and excludes
		 any specimen which only has atypical organisms (i.e. non-TB mycobacteria)


**************************************************************************************************/

CREATE VIEW [dbo].[vwSpecimen] AS
		SELECT
				CASE
					WHEN sr.ReferenceLaboratoryNumber = '' THEN CONCAT('TBSURV', a.IdentityColumn)
					WHEN sr.ReferenceLaboratoryNumber is not null THEN TRIM(sr.ReferenceLaboratoryNumber)
					ELSE CONCAT('TBSURV', a.IdentityColumn)
				END AS 'ReferenceLaboratoryNumber'
				,sr.SpecimenDate
				,sr.LabDataID
				,sr.OpieId
				,sr.ResultSequenceNumber
				,sr.SpecimenTypeCode
				,sr.AuditCreate
				,a.OrganismName
			FROM [labbase2].[dbo].[SpecimenResult] sr
				--inner join because we only want TB specimens and isAtypical flag lives in Anonymised
				INNER JOIN [labbase2].[dbo].[Anonymised] a ON sr.LabDataID = a.LabDataID
				AND a.IsAtypicalOrganismRecord = 0

GO
*/





