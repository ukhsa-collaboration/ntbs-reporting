/*
uspLabSpecimen:
	This stored proc processes specimen data from LabBase2 into a more digestible format

*/

/*USE [NTBS_Reporting_Staging]
GO
/****** Object:  StoredProcedure [dbo].[uspLabSpecimen]    Script Date: 30/11/2019 08:08:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO*/


Create PROCEDURE [dbo].[uspLabSpecimen] AS
	SET NOCOUNT ON

	BEGIN TRY
		
		-- Reset
		DELETE FROM dbo.LabSpecimen

		--First fetch all the matched specimens, regardless of specimen date
		INSERT INTO dbo.LabSpecimen (ReferenceLaboratoryNumber)
			SELECT DISTINCT [ReferenceLaboratoryNumber]
			FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch]
			WHERE [MatchType] = 'Confirmed'

		
		--Now fetch all the unmatched specimens for the last three years
		--Use the View that has been created so there is a consistent LabRefNumber populated for every record
		INSERT INTO dbo.LabSpecimen (ReferenceLaboratoryNumber)
			SELECT DISTINCT s.ReferenceLaboratoryNumber FROM
				[dbo].[vwSpecimen] s
			WHERE YEAR(s.SpecimenDate) IN (SELECT NotificationYear FROM vwNotificationYear)
			AND s.ReferenceLaboratoryNumber NOT IN (SELECT ReferenceLaboratoryNumber FROM LabSpecimen)



		/*START OF SPECIMEN TYPE CODE CALCULATION*/
				-- Select the most specific SpecimenTypeCode (e.g. Pus) available for the Specimen. This may have changed over time
				-- so pick the one with the lowest rank (i.e. 1 rather than 99)

			UPDATE [dbo].[LabSpecimen] SET SpecimenTypeCode = Q2.SampleName FROM
		
				-- second query joins the Rank number to the matching sample name
				(SELECT Q1.ReferenceLaboratoryNumber, Q1.MinRank, sm2.SampleName FROM

						-- innermost query, finds the lowest ranked specimen type for each specimen
						-- so that 'Unknown' will be picked if that is the best available, but if one entry says Unknown
						-- and one says Pus, the Pus will be selected
						(SELECT vs.ReferenceLaboratoryNumber, MIN(sm.SampleRank) As 'MinRank' FROM 
									[dbo].[vwSpecimen] vs
									INNER JOIN [dbo].[LabSpecimen] ls ON 
										vs.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
									LEFT OUTER JOIN [dbo].SampleMapping sm ON
										vs.SpecimenTypeCode = sm.SampleName
								GROUP BY vs.ReferenceLaboratoryNumber) as Q1
			
				LEFT OUTER JOIN SampleMapping sm2 ON sm2.SampleRank = Q1.MinRank) as Q2

			WHERE [dbo].[LabSpecimen].ReferenceLaboratoryNumber = Q2.ReferenceLaboratoryNumber

		/*END OF SPECIMEN TYPE CODE CALCULATION*/

		


		/*START OF REQUESTING LAB NAME, REF LAB + PATIENT DEMOGRAPHICS*/


		-- we are looking for the most recent anonymised record for a given specimen
		-- we are using the 'IdentityColumn' in anonymisedto find this

		UPDATE [dbo].[LabSpecimen] SET 
			 LaboratoryName = Q2.LaboratoryName
			,ReferenceLaboratory = Q2.ReferenceLaboratory
			,PatientNhsNumber = Q2.NHSNumber 
			,PatientBirthDate = Q2.PatientBirthDate
			--TODO: remove PatientName calculation from here - store separate values in LabSpecimen
			,PatientName = Q2.PatientName
			,PatientGivenName = Q2.PatientForename
			,PatientFamilyName = Q2.PatientSurname
			,PatientSex = Q2.PatientSex
			,PatientAddress = Q2.PatientAddress
			,PatientPostcode = Q2.Postcode
			
			FROM
			-- second query finds the Lab Name and Demogs from the corresponding anonymised record
			(SELECT		Q1.ReferenceLaboratoryNumber, 
						a.LaboratoryName,
						a.ReferenceLaboratory,
						--TODO: some of the NHS numbers have carriage returns in them
						TRIM(a.PatientNhsNumber) AS 'NHSNumber', 
						a.PatientBirthDate,
						CASE
							WHEN UPPER(TRIM(a.PatientSurname)) ='' THEN TRIM(a.PatientForename)
							WHEN UPPER(TRIM(a.PatientSurname)) is not null THEN CONCAT(UPPER(TRIM(a.PatientSurname)), ', ', TRIM(a.PatientForename))
							ELSE TRIM(a.PatientForename)
						END AS 'PatientName'
						, a.PatientForename
						, a.PatientSurname
						, a.PatientSex
						, TRIM(CONCAT(TRIM(a.AddressLine1), ' ', TRIM(a.AddressLine2), ' ', TRIM(a.AddressLine3))) as PatientAddress
						, TRIM(a.PatientPostcode) AS 'Postcode'
						FROM 
								--innermost query selects the IdentityColumn value of the most recent anonymised record for our specimen
								 (SELECT vs.ReferenceLaboratoryNumber, MAX(vs.[IdentityColumn]) 'MaxID' FROM vwSpecimen vs
									INNER JOIN LabSpecimen ls ON ls.ReferenceLaboratoryNumber = vs.ReferenceLaboratoryNumber
								 GROUP BY vs.ReferenceLaboratoryNumber) AS Q1
						INNER JOIN [$(Labbase2)].[dbo].[Anonymised] a ON 
						a.IdentityColumn = Q1.MaxID) AS Q2

		WHERE [dbo].[LabSpecimen].ReferenceLaboratoryNumber = Q2.ReferenceLaboratoryNumber

		/*END OF REQUESTING LAB NAME + PATIENT DEMOGRAPHICS*/

		/*START OF SPECIMEN DATE*/
		-- it is possible for there to be more than one specimen date for the same specimen in the SpecimenResult table
		-- take the latest one

		UPDATE [dbo].[LabSpecimen] SET SpecimenDate = Q1.MaxDate
			FROM
				(SELECT vs.ReferenceLaboratoryNumber, MAX(vs.SpecimenDate) AS 'MaxDate' 
				FROM vwSpecimen vs
					INNER JOIN LabSpecimen ls ON ls.ReferenceLaboratoryNumber = vs.ReferenceLaboratoryNumber
					GROUP BY vs.ReferenceLaboratoryNumber, vs.SpecimenDate) AS Q1
		WHERE [dbo].[LabSpecimen].ReferenceLaboratoryNumber = Q1.ReferenceLaboratoryNumber	

		/*END OF SPECIMEN DATE*/



		/*START OF SPECIES*/
		-- use the view to map the lab-provided species name to something more standardised

		UPDATE [dbo].[LabSpecimen] SET 
			Species = Q2.OrganismName
			
			FROM
			-- second query attempts to look up the name of the species from the Organism table. If it can't find a mapping, it uses
			-- the lab-supplied value
			(SELECT		Q1.ReferenceLaboratoryNumber, 
						CASE
							WHEN o.OrganismName is null THEN (SELECT TOP (1) [OrganismName] FROM [dbo].[vwSpecimen] WHERE ReferenceLaboratoryNumber = Q1.ReferenceLaboratoryNumber)
							ELSE (o.OrganismName)
						END AS 'OrganismName' 
						FROM 
						--innermost query selects the highest ranked organism for the notification
								 (SELECT vs.ReferenceLaboratoryNumber, MIN(om.OrganismId) AS 'MinRank' FROM vwSpecimen vs
									INNER JOIN LabSpecimen ls ON ls.ReferenceLaboratoryNumber = vs.ReferenceLaboratoryNumber
									INNER JOIN [$(Labbase2)].[dbo].[Anonymised] a on a.LabDataID = vs.LabDataID
									INNER JOIN OrganismNameMapping om on om.OrganismName = a.OrganismName
								 GROUP BY vs.ReferenceLaboratoryNumber
								 ) AS Q1
			LEFT OUTER JOIN [dbo].Organism o ON o.OrganismId = Q1.MinRank) AS Q2

		WHERE [dbo].[LabSpecimen].ReferenceLaboratoryNumber = Q2.ReferenceLaboratoryNumber

		/*END OF SPECIES*/
	
		/*START OF SENSITIVITY RESULT*/

		--First line done individually
		EXEC uspLabSpecimenSensitivityResult 'INH'
		EXEC uspLabSpecimenSensitivityResult 'ETHAM'
		EXEC uspLabSpecimenSensitivityResult 'PYR'
		EXEC uspLabSpecimenSensitivityResult 'RIF'

		--Second line summarised by group
		EXEC uspLabSpecimenSecondLineSensitivityResult 'AMINO'

		EXEC uspLabSpecimenSecondLineSensitivityResult 'QUIN'
		/*END OF SENSITIVITY RESULT*/
		

		/*START OF MDR/XDR RESULT*/
		EXEC uspSpecimenMDRXDR
		/*END OF SENSITIVITY RESULT*/
	
	
	END TRY
	BEGIN CATCH
		THROW
	END CATCH