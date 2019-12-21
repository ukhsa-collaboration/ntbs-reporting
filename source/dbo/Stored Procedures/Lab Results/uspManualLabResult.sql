CREATE PROCEDURE [dbo].[uspManualLabResult]
	
AS
	SET NOCOUNT ON

	BEGIN TRY
		
		-- Reset
		DELETE FROM dbo.ManualLabResult

		--insert a row for every ETS ID in the ReusableNotification table

		INSERT INTO dbo.ManualLabResult(EtsId)
			SELECT DISTINCT [EtsId]
			FROM [dbo].[ReusableNotification] rn


		--1. Microscopy

		--First update rows with no result
		UPDATE dbo.ManualLabResult
		SET Microscopy = 'No Result'
		WHERE EtsId NOT IN 
		(SELECT DISTINCT vm.LegacyId from [dbo].vwManualLabResult vm
		where vm.[Name] = 'Microscopy')

		--Then set results for Micro
		UPDATE dbo.ManualLabResult
		SET Microscopy = 
		
		(SELECT Result from [dbo].vwManualLabResult vm
			WHERE vm.[Name] = 'Microscopy'
			AND vm.LegacyId = dbo.ManualLabResult.EtsId)
		WHERE Microscopy IS NULL

		--2. Histology
		--First update rows with no result
		UPDATE dbo.ManualLabResult
		SET Histology = 'No Result'
		WHERE EtsId NOT IN 
		(SELECT DISTINCT vm.LegacyId from [dbo].vwManualLabResult vm
		where vm.[Name] = 'Histology')

		--Then set results for Histo
		UPDATE dbo.ManualLabResult
		SET Histology = 
		
		(SELECT Result from [dbo].vwManualLabResult vm
			WHERE vm.[Name] = 'Histology'
			AND vm.LegacyId = dbo.ManualLabResult.EtsId)
		WHERE Histology IS NULL

		--3. Culture
		--First update rows with no result
		UPDATE dbo.ManualLabResult
		SET Culture = 'No Result'
		WHERE EtsId NOT IN 
		(SELECT DISTINCT vm.LegacyId from [dbo].vwManualLabResult vm
		where vm.[Name] = 'Mycobacterial Culture')

		--Then set results for Culture
		UPDATE dbo.ManualLabResult
		SET Culture = 
		
		(SELECT Result from [dbo].vwManualLabResult vm
			WHERE vm.[Name] = 'Mycobacterial Culture'
			AND vm.LegacyId = dbo.ManualLabResult.EtsId)
		WHERE Culture IS NULL

		--4	Molecular Amplification
		--First update rows with no result
		UPDATE dbo.ManualLabResult
		SET Amplification = 'No Result'
		WHERE EtsId NOT IN 
		(SELECT DISTINCT vm.LegacyId from [dbo].vwManualLabResult vm
		where vm.[Name] = 'Molecular Amplification')

		--Then set results for Amplification
		UPDATE dbo.ManualLabResult
		SET Amplification =
		(SELECT Result from [dbo].vwManualLabResult vm
			WHERE vm.[Name] = 'Molecular Amplification'
			AND vm.LegacyId = dbo.ManualLabResult.EtsId)
		WHERE Amplification IS NULL
	END TRY
	BEGIN CATCH
		THROW
	END CATCH