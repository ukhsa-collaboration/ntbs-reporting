/*
uspLabSpecimen:
	This stored proc processes specimen data from LabBase2 into a more digestible format

*/

CREATE PROCEDURE [dbo].[uspLabSpecimen] AS
	SET NOCOUNT ON

	BEGIN TRY
		
		/*Reset and reload base data*/

		-- Reset
		TRUNCATE TABLE [dbo].[LabSpecimen]
		TRUNCATE TABLE [dbo].[EtsSpecimenMatch]
		TRUNCATE TABLE [dbo].[StandardisedLabbaseSpecimen]
		TRUNCATE TABLE [dbo].[StandardisedLabbaseSusceptibilityResult]

		-- first populate the temporary table with basic data from LabBase
		-- !!! The migration db uses the same way to make up missing reference laboratory numbers - make sure to keep them in sync: 
		-- https://github.com/PublicHealthEngland/ntbs-data-migration/blob/master/migration/27_aggregate_views/EtsLaboratoryResultsView.sql#L14
		INSERT INTO [dbo].[StandardisedLabbaseSpecimen]
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

		--refresh the EtsSpecimenMatch table
		INSERT INTO [dbo].[EtsSpecimenMatch](LegacyId, ReferenceLaboratoryNumber, EarliestMatchDate, SpecimenDate, Denotified, Draft, Automatched)
			SELECT DISTINCT 
				n.LegacyId 
				,s.ReferenceLaboratoryNumber 
				,MIN(lr.auditcreate) OVER (PARTITION BY s.ReferenceLaboratoryNumber) AS EarliestMatchDate
				,MIN(s.SpecimenDate) OVER (PARTITION BY s.ReferenceLaboratoryNumber) AS SpecimenDate 
				,CASE WHEN n.DenotificationId IS NOT NULL THEN 1 ELSE 0 END AS Denotified
				,CASE WHEN n.Submitted = 0 THEN 1 ELSE 0 END AS Draft
				,MAX(CASE WHEN lr.AutoMatched = 1 THEN 1 ELSE 0 END) OVER (PARTITION BY s.ReferenceLaboratoryNumber) AS Automatched
			FROM [$(ETS)].[dbo].[Notification] n
				INNER JOIN [$(ETS)].[dbo].[LaboratoryResult] lr ON lr.NotificationId = n.Id
				INNER JOIN [dbo].[StandardisedLabbaseSpecimen] s ON s.OpieId = lr.OpieId
			WHERE 
				n.[AuditDelete] IS NULL
				--include denotified and draft records in this query, so these can be highlighted as bad matches, so unlike most similar queries we do not include
				--n.DenotificationId IS NULL AND n.Submitted = 1
				AND lr.OpieId IS NOT NULL
				AND lr.AuditDelete IS NULL

		--Find the specimens to insert into LabSpecimen
		--First fetch all the matched specimens, regardless of specimen date
		INSERT INTO dbo.LabSpecimen (ReferenceLaboratoryNumber)
			SELECT DISTINCT [ReferenceLaboratoryNumber]
			FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch]
			WHERE [MatchType] = 'Confirmed'

		
		--Now fetch all the unmatched specimens for the last three years
		INSERT INTO dbo.LabSpecimen (ReferenceLaboratoryNumber)
			SELECT DISTINCT s.ReferenceLaboratoryNumber FROM
				[dbo].[StandardisedLabbaseSpecimen] s
			WHERE YEAR(s.SpecimenDate) IN (SELECT NotificationYear FROM vwNotificationYear)
			AND s.ReferenceLaboratoryNumber NOT IN (SELECT ReferenceLaboratoryNumber FROM LabSpecimen)

		--populate the EarliestRecordDate so we can find newly arrived specimens
		UPDATE ls SET
			EarliestRecordDate = Q1.EarliestRecordDate
			FROM LabSpecimen ls
				INNER JOIN 
				(SELECT ReferenceLaboratoryNumber, MIN(AuditCreate) AS EarliestRecordDate 
				FROM StandardisedLabbaseSpecimen GROUP BY ReferenceLaboratoryNumber) AS Q1 ON Q1.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
	


		--load basic information about drug sensitivity results from Labase, but only for the specimens in LabSpecimen
		--impacts performance too much to pull all the data across
		INSERT INTO [dbo].[StandardisedLabbaseSusceptibilityResult]
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
				FROM StandardisedLabbaseSpecimen lbs
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


		EXEC uspMigrationDubiousSpecimenMatches
	
	END TRY
	BEGIN CATCH
		THROW
	END CATCH