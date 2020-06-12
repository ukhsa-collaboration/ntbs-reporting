/*
uspLabSpecimen:
	This stored proc processes specimen data from LabBase2 into a more digestible format

*/

CREATE PROCEDURE [dbo].[uspLabSpecimen] AS
	SET NOCOUNT ON

	BEGIN TRY
		
		/*Reset and reload base data*/

		-- Reset
		DELETE FROM [dbo].[LabSpecimen]
		DELETE FROM [dbo].[LabbaseSpecimen]
		DELETE FROM [dbo].[LabBaseSusceptibilityResult]

		-- first populate the temporary table with basic data from LabBase
		INSERT INTO [dbo].[LabbaseSpecimen]
			([ReferenceLaboratoryNumber]
		  ,[SpecimenDate]
		  ,[LabDataID]
		  ,[OpieId]
		  ,[IdentityColumn]
		  ,[SpecimenTypeCode]
		  ,[AuditCreate]
		  ,[OrganismName])
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
				FROM [$(Labbase2)].[dbo].[Anonymised] a 
					--inner join because we only want TB specimens and isAtypical flag lives in Anonymised
					INNER JOIN [$(Labbase2)].[dbo].[SpecimenResult] sr ON sr.LabDataID = a.LabDataID
					AND a.IsAtypicalOrganismRecord = 0
					AND a.MergedRecord = 0


		--Find the specimens to insert into LabSpecimen
		--First fetch all the matched specimens, regardless of specimen date
		INSERT INTO dbo.LabSpecimen (ReferenceLaboratoryNumber)
			SELECT DISTINCT [ReferenceLaboratoryNumber]
			FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch]
			WHERE [MatchType] = 'Confirmed'

		
		--Now fetch all the unmatched specimens for the last three years
		INSERT INTO dbo.LabSpecimen (ReferenceLaboratoryNumber)
			SELECT DISTINCT s.ReferenceLaboratoryNumber FROM
				[dbo].[LabbaseSpecimen] s
			WHERE YEAR(s.SpecimenDate) IN (SELECT NotificationYear FROM vwNotificationYear)
			AND s.ReferenceLaboratoryNumber NOT IN (SELECT ReferenceLaboratoryNumber FROM LabSpecimen)

		--load basic information about drug sensitivity results from Labase, but only for the specimens in LabSpecimen
		--impacts performance too much to pull all the data across
		INSERT INTO [dbo].[LabBaseSusceptibilityResult]
			([ReferenceLaboratoryNumber],
			[AntibioticOutputName],
			[IsWGS],
			[ResultOutputName],
			[Rank])

				SELECT DISTINCT 
					lbs.ReferenceLaboratoryNumber, 
					am.AntibioticOutputName, 
					am.IsWGS, 
					rm.ResultOutputName, 
					rm.[Rank] 
				FROM LabbaseSpecimen lbs
					INNER JOIN LabSpecimen ls ON ls.ReferenceLaboratoryNumber = lbs.ReferenceLaboratoryNumber
					INNER JOIN [$(Labbase2)].dbo.Susceptibility su ON su.LabDataID = lbs.LabDataID
					LEFT OUTER JOIN [dbo].[AntibioticMapping] am  ON am.AntibioticCode = su.AntibioticCode
					LEFT OUTER JOIN [dbo].[ResultMapping] rm  ON rm.Result = su.SusceptibilityResult
				WHERE ResultOutputName NOT IN ('New', 'Awaiting', 'No result')

		--Now populate each row with the relevant summarised information

		UPDATE [dbo].[LabSpecimen] SET 

			SpecimenTypeCode = gs.SpecimenTypeCode,
			SpecimenDate = gs.SpecimenDate,
			Species = gs.Species,
			LaboratoryName = a.LaboratoryName,
			ReferenceLaboratory = CASE
									WHEN a.ReferenceLaboratory = 'NMRL' THEN 'NMRS'
									ELSE a.ReferenceLaboratory
								  END,
			PatientNhsNumber = TRIM(REPLACE(a.PatientNhsNumber,CHAR(13),'')),
			PatientBirthDate = a.PatientBirthDate,
			PatientName = CASE
							WHEN UPPER(TRIM(a.PatientSurname)) ='' THEN TRIM(a.PatientForename)
							WHEN UPPER(TRIM(a.PatientSurname)) is not null THEN CONCAT(UPPER(TRIM(a.PatientSurname)), ', ', TRIM(a.PatientForename))
							ELSE TRIM(a.PatientForename)
						END, 
			PatientGivenName = TRIM(a.PatientForename),
			PatientFamilyName = TRIM(a.PatientSurname),
			PatientSex = TRIM(a.PatientSex),
			PatientAddress = TRIM(CONCAT(TRIM(a.AddressLine1), ' ', TRIM(a.AddressLine2), ' ', TRIM(a.AddressLine3))),
			PatientPostcode = TRIM(a.PatientPostcode),
			INH = ss.INH,
			RIF = ss.RIF,
			EMB = ss.EMB,
			PZA = ss.PZA,
			AMINO = ss.AMINO,
			QUIN = ss.QUIN
			
			FROM 
				[dbo].[LabSpecimen] ls
				CROSS APPLY [dbo].[ufnGetSpecimenInfo](ls.ReferenceLaboratoryNumber) gs
				CROSS APPLY [dbo].[ufnGetSpecimenSusceptibilityInfo](ls.ReferenceLaboratoryNumber) ss
				INNER JOIN [$(Labbase2)].[dbo].[Anonymised] a ON a.IdentityColumn = gs.IdentityColumn
				

		/*START OF MDR/XDR RESULT*/
		EXEC uspSpecimenMDRXDR
		/*END OF SENSITIVITY RESULT*/
	
	END TRY
	BEGIN CATCH
		THROW
	END CATCH