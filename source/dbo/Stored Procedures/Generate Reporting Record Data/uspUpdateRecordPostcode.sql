/*
	This procedure creates a cleaned postcode from the value supplied from the notification system (ETS or NTBS)
	Provided the postcode matches the format and length of a UK postcode, this will insert a single space 3 characters from
	the right hand side of the string. Otherwise, it will leave the postcode value unchanged
*/

CREATE PROCEDURE [dbo].[uspUpdateRecordPostcode] AS
	SET NOCOUNT ON

	BEGIN TRY


		IF object_id('tempdb.dbo.#RecordPostcodes','U') IS NOT NULL
		BEGIN
			DROP TABLE #RecordPostcodes
		END

		SELECT DISTINCT
			PersonalDetailsId
			,PostcodeToLookup AS CleanedPostcode
		INTO #RecordPostcodes
		FROM [dbo].[Record_PersonalDetails]
		WHERE PostcodeToLookup IS NOT NULL
			AND LEN(PostcodeToLookup) >= 5
			AND LEN(PostcodeToLookup) <= 7
			AND PostcodeToLookup LIKE '%[^0-9]%'


		UPDATE #RecordPostcodes
			SET CleanedPostcode = SUBSTRING(CleanedPostcode, 1, LEN(CleanedPostcode)-3) + ' ' + RIGHT(CleanedPostcode, 3)

		UPDATE r
		SET
			Postcode = n.CleanedPostcode
		FROM [Record_PersonalDetails] r
			INNER JOIN #RecordPostcodes n ON n.PersonalDetailsId = r.PersonalDetailsId

	END TRY
	BEGIN CATCH
		THROW
	END CATCH
GO
