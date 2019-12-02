USE [NTBS_Reporting_Staging]
GO
/****** Object:  StoredProcedure [dbo].[uspLabSpecimen]    Script Date: 30/11/2019 08:08:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[uspLabSpecimen] AS
	SET NOCOUNT ON

	BEGIN TRY
		
		-- Reset
		DELETE FROM dbo.LabSpecimen

		INSERT INTO dbo.LabSpecimen
			 
			/*this brings back info about each specimen - date, type, requesting lab, ref lab, species and patient info - for notifications in January 2019*/
			SELECT DISTINCT
				CASE
					WHEN sr.ReferenceLaboratoryNumber is not null THEN TRIM(sr.ReferenceLaboratoryNumber)
					ELSE CONCAT('TBSURV', a.IdentityColumn)
				END AS 'ReferenceLaboratoryNumber'
				--TODO: SPECIMEN DATE MAY BE DIFFERENT BETWEEN ENTRIES FOR THE SAME SPECIMEN
				,sr.SpecimenDate
				--SPECIMEN TYPE CODE AND LAB NAME MAY BE DIFFERENT BETWEEN ENTRIES FOR THE SAME SPECIMEN
				,NULL
				--,dbo.ufnGetSampleType(sr.ReferenceLaboratoryNumber)			As 'SpecimenTypeCode'
				,NULL
				,TRIM(a.ReferenceLaboratory) AS 'ReferenceLaboratory'
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
			FROM [labbase2].[dbo].[SpecimenResult] sr
				LEFT OUTER JOIN [labbase2].[dbo].[Anonymised] a ON sr.LabDataID = a.LabDataID
				--TODO Temp fix to bring back less data during dev
				WHERE sr.SpecimenDate between '2019-06-28' and '2019-07-27'
			ORDER BY ReferenceLaboratoryNumber


		/*START OF SPECIMEN TYPE CODE CALCULATION*/
				-- Select the most specific SpecimenTypeCode (e.g. Pus) available for the Specimen. This may have changed over time
				-- so pick the one with the lowest rank (i.e. 1 rather than 99)

			UPDATE [dbo].[LabSpecimen] SET SpecimenTypeCode = Q2.SampleName FROM
		
				-- second query joins the Rank number to the matching sample name
				(SELECT Q1.ReferenceLaboratoryNumber, Q1.MinRank, sm2.SampleName FROM

						-- innermost query, finds the lowest ranked specimen type for each specimen
						-- so that 'Unknown' will be picked if that is the best available, but if one entry says Unknown
						-- and one says Pus, the Pus will be selected
						(SELECT sr.ReferenceLaboratoryNumber, MIN(sm.SampleRank) As 'MinRank' FROM 
									[labbase2].[dbo].[SpecimenResult] sr
									--TODO: this does not handle the specimens where we have had to calculate a RefLabNumber
									--from anonmyised.  It might be better to have a view on [labbase2].[dbo].[SpecimenResult]
									-- which sorts this out
									INNER JOIN [dbo].[LabSpecimen] ls ON 
										sr.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
									LEFT OUTER JOIN [dbo].SampleMapping sm ON
										sr.SpecimenTypeCode = sm.SampleName
								GROUP BY sr.ReferenceLaboratoryNumber) as Q1
			
				LEFT OUTER JOIN SampleMapping sm2 ON sm2.SampleRank = Q1.MinRank) as Q2

			WHERE [dbo].[LabSpecimen].ReferenceLaboratoryNumber = Q2.ReferenceLaboratoryNumber

		/*END OF SPECIMEN TYPE CODE CALCULATION*/

		


		/*START OF REQUESTING LAB NAME + PATIENT DEMOGRAPHICS*/


		-- we are looking for the most recent anonymised record for a given specimen. The problem is, there may be multiple records
		-- with the exact same timestamp (AuditCreate).
		-- so far, in each pair one has 'IsAtypicalOrganismRecord' set to 1, and I suspect that we want to ignore these anyway
		-- Examples: ('A19U002771A', 'A19U001562A')
		-- TEMP FIX: choosing a date range I know doesn't have this problem, to discuss with Adil.  I suspect any specimen which only
		-- has atypical results should be excluded
		-- so far I can't see any reason not to just select the most recent record to get the demographics


		UPDATE [dbo].[LabSpecimen] SET 
			 LaboratoryName = Q2.LaboratoryName
			,PatientNhsNumber = Q2.NHSNumber 
			,PatientBirthDate = Q2.PatientBirthDate
			,PatientName = Q2.PatientName
			,PatientSex = Q2.PatientSex
			,PatientAddress = Q2.PatientAddress
			,PatientPostcode = Q2.Postcode
			
			FROM
			-- second query finds the Lab Name from the corresponding anonymised record
			(SELECT		Q1.ReferenceLaboratoryNumber, 
						a.LaboratoryName, 
						TRIM(a.PatientNhsNumber) AS 'NHSNumber', 
						a.PatientBirthDate,
						CASE
							WHEN UPPER(TRIM(a.PatientSurname)) ='' THEN TRIM(a.PatientForename)
							WHEN UPPER(TRIM(a.PatientSurname)) is not null THEN CONCAT(UPPER(TRIM(a.PatientSurname)), ', ', TRIM(a.PatientForename))
							ELSE TRIM(a.PatientForename)
						END AS 'PatientName'
						, a.PatientForename 
						, a.PatientSex
						, TRIM(CONCAT(TRIM(a.AddressLine1), ' ', TRIM(a.AddressLine2), ' ', TRIM(a.AddressLine3))) as PatientAddress
						, TRIM(a.PatientPostcode) AS 'Postcode'
						FROM 
						--innermost query selects the AuditCreate date of the most recent anonymised record for our specimen
						(SELECT sr.ReferenceLaboratoryNumber, MAX(a.AuditCreate) AS 'MaxAudit'
							from [labbase2].[dbo].[SpecimenResult] sr
							--for some reason, not all specimen result entries have a corresponding anonymised entry?	
								INNER JOIN [labbase2].[dbo].[Anonymised] a ON a.LabDataID = sr.LabDataID
								INNER JOIN [dbo].[LabSpecimen] ls ON  sr.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
						 GROUP BY sr.ReferenceLaboratoryNumber) AS Q1
			INNER JOIN [labbase2].[dbo].[SpecimenResult] sr ON sr.ReferenceLaboratoryNumber = Q1.ReferenceLaboratoryNumber
			INNER JOIN [labbase2].[dbo].[Anonymised] a ON 
				a.LabDataID = sr.LabDataID AND a.AuditCreate = Q1.MaxAudit) AS Q2

		WHERE [dbo].[LabSpecimen].ReferenceLaboratoryNumber = Q2.ReferenceLaboratoryNumber

		/*END OF REQUESTING LAB NAME + PATIENT DEMOGRAPHICS*/

		/*START OF SPECIES*/
		-- at the moment, this is also just looking up the most recent anonymised record and then mapping its species
		-- to a record in the Organism lookup tables, so could actually be part of the query above
		-- many of the records have species names which don't exist in our mapping

		UPDATE [dbo].[LabSpecimen] SET 
			Species = Q2.OrganismName
			
			FROM
			-- second query attempts to look up the name of the species from the Organism table. If it can't find a mapping, it uses
			-- the lab-supplied value
			(SELECT		Q1.ReferenceLaboratoryNumber, 
						om.OrganismId,
						CASE
							WHEN om.OrganismID is null THEN TRIM(a.OrganismName)
							ELSE (o.OrganismName)
						END AS 'OrganismName' 
						FROM 
						--innermost query selects the AuditCreate date of the most recent anonymised record for our specimen
						(SELECT sr.ReferenceLaboratoryNumber, MAX(a.AuditCreate) AS 'MaxAudit'
							from [labbase2].[dbo].[SpecimenResult] sr
							--for some reason, not all specimen result entries have a corresponding anonymised entry?	
								INNER JOIN [labbase2].[dbo].[Anonymised] a ON a.LabDataID = sr.LabDataID
								INNER JOIN [dbo].[LabSpecimen] ls ON  sr.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
						 GROUP BY sr.ReferenceLaboratoryNumber) AS Q1
						 --end of innermost query

			INNER JOIN [labbase2].[dbo].[SpecimenResult] sr ON sr.ReferenceLaboratoryNumber = Q1.ReferenceLaboratoryNumber
			INNER JOIN [labbase2].[dbo].[Anonymised] a ON 
				a.LabDataID = sr.LabDataID AND a.AuditCreate = Q1.MaxAudit
			LEFT OUTER JOIN [dbo].OrganismNameMapping om on a.OrganismName = om.OrganismName
			LEFT OUTER JOIN [dbo].Organism o ON o.OrganismId = om.OrganismId) AS Q2

		WHERE [dbo].[LabSpecimen].ReferenceLaboratoryNumber = Q2.ReferenceLaboratoryNumber

		/*END OF SPECIES*/
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
