/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.MDR
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationMdr] AS
	BEGIN TRY
		SET NOCOUNT ON

		-- 1. Both INH and RIF are set to 'Resistant'
		UPDATE dbo.ReusableNotification_ETS SET
			MDR = 'Yes'
		WHERE MDR IS NULL
			AND (INH = 'Resistant' AND RIF = 'Resistant')

		-- 2. One of INH and RIF (or both) is 'Sensitive'
		UPDATE dbo.ReusableNotification_ETS SET
			MDR = 'No'
		WHERE MDR IS NULL
			AND (INH = 'Sensitive' OR RIF = 'Sensitive')

		-- 3. One of INH and RIF (or both) is 'No result' or 'Unknown'
		UPDATE dbo.ReusableNotification_ETS SET
			MDR = 'No result'
		WHERE MDR IS NULL
			AND (
					   INH = 'No result' 
					OR RIF = 'No result' 
					OR INH = 'Unknown' 
					OR RIF = 'Unknown'
					--OR INH = 'Failed' 
					--OR RIF = 'Failed' 
				)

		-- 4. An error has occurred
		UPDATE dbo.ReusableNotification_ETS SET
			MDR = 'Error: Invalid value'
		WHERE MDR IS NULL
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
