CREATE PROCEDURE [dbo].[uspResultMapping] AS


	SET NOCOUNT ON

	BEGIN TRY
		DELETE FROM ResultMapping

		INSERT INTO ResultMapping VALUES ('R', 'Resistant', 1)
		INSERT INTO ResultMapping VALUES ('Resistant', 'Resistant', 1)
		INSERT INTO ResultMapping VALUES ('S', 'Sensitive', 2)
		INSERT INTO ResultMapping VALUES ('Sensitive', 'Sensitive', 2)
		--Failed and Unknown are synonymous for our purposes, but are mapped to different ranks
		--in case it is useful for debugging
		INSERT INTO ResultMapping VALUES ('F', 'Unknown', 3)
		INSERT INTO ResultMapping VALUES ('Failed', 'Unknown', 3)
		INSERT INTO ResultMapping VALUES ('U', 'Unknown', 4)
		INSERT INTO ResultMapping VALUES ('Unknown', 'Unknown', 4)
		INSERT INTO ResultMapping VALUES ('Awaiting', 'Awaiting', 5)
		INSERT INTO ResultMapping VALUES ('No Result', 'No result', 6)
		INSERT INTO ResultMapping VALUES ('New', 'New', 7)



	END TRY
	BEGIN CATCH
		THROW
	END CATCH