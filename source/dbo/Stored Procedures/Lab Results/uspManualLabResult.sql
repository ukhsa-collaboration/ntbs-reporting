CREATE PROCEDURE [dbo].[uspManualLabResult]
	
AS
	SET NOCOUNT ON

	BEGIN TRY
		
		-- Reset
		DELETE FROM dbo.ManualLabResult

		EXEC dbo.uspManualLabResultAll

		EXEC dbo.uspManualLabResultMicroscopy

		--insert a row for every ETS ID in the ReusableNotification table

		INSERT INTO dbo.ManualLabResult(EtsId)
			SELECT DISTINCT [EtsId]
			FROM [dbo].[ReusableNotification] rn


		--1. Microscopy
		--First set the rows with a result
		
		UPDATE dbo.ManualLabResult
		SET Microscopy = 
		
		(SELECT Result from [dbo].ManualLabResultAll mra
			WHERE mra.[TestType]  = 'Microscopy'
			AND mra.EtsId = dbo.ManualLabResult.EtsId)
		WHERE Microscopy IS NULL

		--Then update rows with no result
		UPDATE dbo.ManualLabResult
		SET Microscopy = 'No Result'
		WHERE Microscopy IS NULL

		--2. MicroscopySputum
		--First set the rows with a result
		UPDATE dbo.ManualLabResult
		SET MicroscopySputum = 
		
		(SELECT Result from [dbo].ManualLabResultMicroscopy mrs
			WHERE mrs.Sputum = 1
			AND mrs.EtsId = dbo.ManualLabResult.EtsId)
		WHERE MicroscopySputum IS NULL
		
		--Then update rows with no result

		UPDATE dbo.ManualLabResult
		SET MicroscopySputum = 'No Result'
		WHERE MicroscopySputum IS NULL


		--3. MicroscopyNonSputum
		--First set the rows with a result
		UPDATE dbo.ManualLabResult
		SET MicroscopyNonSputum = 
		
		(SELECT Result from [dbo].ManualLabResultMicroscopy mrs
			WHERE mrs.Sputum = 0
			AND mrs.EtsId = dbo.ManualLabResult.EtsId)
		WHERE MicroscopyNonSputum IS NULL
		
		--Then update rows with no result

		UPDATE dbo.ManualLabResult
		SET MicroscopyNonSputum = 'No Result'
		WHERE MicroscopyNonSputum IS NULL

		--4. Histology
		
		--Set results for Histo
		UPDATE dbo.ManualLabResult
		SET Histology = 
		
		(SELECT Result from [dbo].ManualLabResultAll mra
			WHERE mra.[TestType]  = 'Histology'
			AND mra.EtsId = dbo.ManualLabResult.EtsId)
		WHERE Histology IS NULL

		--Then update rows with no result
		UPDATE dbo.ManualLabResult
		SET Histology = 'No Result'
		WHERE Histology IS NULL


		--5. Culture
		

		--Then set results for Culture
		UPDATE dbo.ManualLabResult
		SET Culture = 
		
		(SELECT Result from [dbo].ManualLabResultAll mra
			WHERE mra.[TestType] = 'Mycobacterial Culture'
			AND mra.EtsId = dbo.ManualLabResult.EtsId)
		WHERE Culture IS NULL

		--Then update rows with no result
		UPDATE dbo.ManualLabResult
		SET Culture = 'No Result'
		WHERE Culture IS NULL

		--6	Molecular Amplification
		
		--Set results for Amplification
		UPDATE dbo.ManualLabResult
		SET Amplification =
		(SELECT Result from [dbo].ManualLabResultAll mra
			WHERE mra.[TestType] = 'Molecular Amplification'
			AND mra.EtsId = dbo.ManualLabResult.EtsId)
		WHERE Amplification IS NULL


		--Then update rows with no result
		UPDATE dbo.ManualLabResult
		SET Amplification = 'No Result'
		WHERE Amplification IS NULL

		--finally clear out the look-up tables ManualLabResultAll and ManualLabResultMicroscopy
		DELETE FROM [dbo].ManualLabResultAll
		DELETE FROM [dbo].ManualLabResultMicroscopy

	END TRY
	BEGIN CATCH
		THROW
	END CATCH