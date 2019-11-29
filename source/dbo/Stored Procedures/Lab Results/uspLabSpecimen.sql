/***************************************************************************************************
Desc:   This creates a single record for each specimen, containing information about it and 
		summarises the demographics associated with it

**************************************************************************************************/
CREATE PROCEDURE [dbo].[uspLabSpecimen] AS
	SET NOCOUNT ON

	BEGIN TRY
		
		-- Reset
		DELETE FROM dbo.LabSpecimen

		INSERT INTO dbo.LabSpecimen
			/*this brings back info about each specimen - date, type, requesting lab, ref lab, species and patient info - for notifications in January 2019*/
			SELECT DISTINCT 
				sr.ReferenceLaboratoryNumber
				,FORMAT(sr.SpecimenDate, 'dd MMM yyyy') AS 'SpecimenDate'
				,sr.SpecimenTypeCode
				,TRIM(a.LaboratoryName) AS 'RequestingLaboratoryName'
				,TRIM(a.ReferenceLaboratory) AS 'ReferenceLaboratory'
				--, [NTBS_R1_Reporting_Staging].dbo.ufnGetSpecies(n.Id) AS 'Species'
				--TODO manage not putting a comma in if surname is empty
				,CONCAT(TRIM(UPPER(a.PatientSurname)), ', ', TRIM(a.PatientForename)) AS 'PatientName'
				,a.PatientNhsNumber
				,FORMAT(a.PatientBirthDate, 'dd MMM yyyy') AS 'PatientBirthDate'
				,a.PatientSex
				,(CONCAT(TRIM(a.AddressLine1), ' ', TRIM(a.AddressLine2), ' ', TRIM(a.AddressLine3))) AS 'PatientAddress'
				,a.PatientPostcode
			FROM [labbase2].[dbo].[SpecimenResult] sr
				LEFT OUTER JOIN [dbo].[Anonymised] a ON sr.LabDataID = a.LabDataID
				--TODO TEMP MOVE TO REMOVE NULL REF LAB NUMBER and temp fix to bring back less data during dev
				WHERE sr.ReferenceLaboratoryNumber is not Null
  