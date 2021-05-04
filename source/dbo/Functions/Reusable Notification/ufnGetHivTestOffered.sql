/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.HivTestOffered
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE FUNCTION [dbo].[ufnGetHivTestOffered] (
	@HivTestOffered NVARCHAR(255)
)
	RETURNS NVARCHAR(255)
AS
	BEGIN
		DECLARE @ReturnValue AS NVARCHAR(255) = NULL

		-- 1. HIVTestOffered is 'HIV status already known'
		IF (@HivTestOffered = 'HIVStatusKnown')
			SET @ReturnValue = 'Status already known'

		-- 2. HIVTestOffered is 'Not offered'
		IF (@HivTestOffered = 'NotOffered')
			SET @ReturnValue = 'Not offered'

		-- 3. HIVTestOffered is one of 'Offered and done', 'Offered but not done', 'Offered but refused'
		IF (@HivTestOffered = 'Offered' OR @HivTestOffered = 'OfferedButNotDone' OR @HivTestOffered = 'OfferedButRefused')
			SET @ReturnValue = 'Offered'

		-- 4. HIVTestOffered is NULL
		IF (@HivTestOffered IS NULL)
			SET @ReturnValue = NULL

		RETURN @ReturnValue
	END