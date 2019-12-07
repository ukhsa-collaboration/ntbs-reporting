USE [NTBS_Reporting_Staging]
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
					WHEN a.ReferenceLaboratoryNumber = '' THEN CONCAT('TBSURV', a.IdentityColumn)
					WHEN a.ReferenceLaboratoryNumber is not null THEN TRIM(a.ReferenceLaboratoryNumber)
					ELSE CONCAT('TBSURV', a.IdentityColumn)
				END AS 'ReferenceLaboratoryNumber'
				,sr.SpecimenDate
				,sr.LabDataID
				,a.OpieId
				,a.IdentityColumn
				,sr.SpecimenTypeCode
				,a.AuditCreate
				,a.OrganismName
			FROM [labbase2].[dbo].[Anonymised] a 
				--inner join because we only want TB specimens and isAtypical flag lives in Anonymised
				INNER JOIN [labbase2].[dbo].[SpecimenResult] sr ON sr.LabDataID = a.LabDataID
				AND a.IsAtypicalOrganismRecord = 0
				AND a.MergedRecord = 0

GO





