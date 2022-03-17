CREATE PROCEDURE [dbo].[uspUpdateRecordNhsNumber] AS
	SET NOCOUNT ON

	BEGIN TRY

		UPDATE [dbo].[Record_PersonalDetails]
		SET NhsNumberToLookup =
			CASE
				WHEN LEN(REPLACE(REPLACE(NhsNumberToLookup, ' ', ''), '-', '')) = 10
					THEN REPLACE(REPLACE(NhsNumberToLookup, ' ', ''), '-', '')
				ELSE NULL
			END

		UPDATE [dbo].[Record_PersonalDetails]
			SET NhsNumber = SUBSTRING(NhsNumberToLookup, 1, 3) +
				' ' + SUBSTRING(NhsNumberToLookup, 4, 3) +
				' ' + SUBSTRING(NhsNumberToLookup, 7, 4)
			WHERE NhsNumberToLookup NOT LIKE '%[^0-9]%'

	END TRY
	BEGIN CATCH
		THROW
	END CATCH
GO
