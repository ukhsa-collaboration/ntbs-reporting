/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.XDR
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationXdr] AS
	BEGIN TRY
		SET NOCOUNT ON

		-- 1 MDR is not set to 'Yes'
		-- a. MDR is set to 'No' - set XDR to 'No'
		UPDATE dbo.ReusableNotification_ETS SET
			XDR = 'No'
		WHERE XDR IS NULL
			AND MDR = 'No'

		-- 1 MDR is not set to 'Yes'
		-- b. MDR is set to 'No result' - set XDR to 'No result'
		UPDATE dbo.ReusableNotification_ETS SET
			XDR = 'No result'
		WHERE XDR IS NULL
			AND MDR = 'No result'

		-- 2. Both AMINO and QUIN are set to 'Resistant'
		UPDATE dbo.ReusableNotification_ETS SET
			XDR = 'Yes'
		WHERE XDR IS NULL
			AND MDR = 'Yes'
			AND (AMINO = 'Resistant' AND QUIN = 'Resistant')

		-- 3. One of AMINO and QUIN (or both) is 'Sensitive'
		UPDATE dbo.ReusableNotification_ETS SET
			XDR = 'No'
		WHERE XDR IS NULL
			AND MDR = 'Yes'
			AND (AMINO = 'Sensitive' OR QUIN = 'Sensitive')

		-- 4. One of AMINO and QUIN (or both) is 'No result' or 'Unknown'
		UPDATE dbo.ReusableNotification_ETS SET
			XDR = 'No result'
		WHERE XDR IS NULL
			AND MDR = 'Yes'
			AND (
					   AMINO = 'No result' 
					OR QUIN = 'No result' 
					OR AMINO = 'Unknown' 
					OR QUIN = 'Unknown'
					--OR AMINO = 'Failed' 
					--OR QUIN = 'Failed' 
				)

		-- 5. An error has occurred
		UPDATE dbo.ReusableNotification_ETS SET
			XDR = 'Error: Invalid value'
		WHERE XDR IS NULL
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
