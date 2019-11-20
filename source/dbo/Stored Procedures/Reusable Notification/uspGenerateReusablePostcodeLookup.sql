
CREATE PROCEDURE [dbo].[uspGenerateReusablePostcodeLookup] AS
	SET NOCOUNT ON

	BEGIN TRY
		-- Reset
		DELETE FROM PostcodeLookup

		INSERT INTO dbo.PostcodeLookup
			SELECT 
				Id, 
				Pcd2,
				NULL
			FROM [$(ETS)].dbo.Postcode

		-- Populate table to remove spaces from postcodes
		UPDATE dbo.PostcodeLookup
			SET Pcd2NoSpaces = REPLACE(Pcd2, ' ', '')
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
