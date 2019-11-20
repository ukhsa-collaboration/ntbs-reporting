/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.DrugResistanceProfile
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationDrugResistanceProfile] AS
	BEGIN TRY
		SET NOCOUNT ON

		-- 1. MDR has the value 'Yes'
		UPDATE dbo.ReusableNotification SET
			DrugResistanceProfile = 'RR/MDR/XDR'
		WHERE DrugResistanceProfile IS NULL
			AND MDR = 'Yes'

		-- 2. RIF has the value 'Resistant'
		UPDATE dbo.ReusableNotification SET
			DrugResistanceProfile = 'RR/MDR/XDR'
		WHERE DrugResistanceProfile IS NULL
			AND RIF = 'Resistant'

		-- 3. INH has the value 'Resistant'
		UPDATE dbo.ReusableNotification SET
			DrugResistanceProfile = 'INH resistant'
		WHERE DrugResistanceProfile IS NULL
			AND INH = 'Resistant'

		-- 4. INH and RIF are both 'Sensitive' but one or both of EMB and PZA are 'Resistant'
		UPDATE dbo.ReusableNotification SET
			DrugResistanceProfile = 'INH+RIF sensitive'
		WHERE DrugResistanceProfile IS NULL
			AND INH = 'Sensitive'
			AND RIF = 'Sensitive'
			AND (EMB = 'Resistant' OR PZA = 'Resistant')

		-- 5. INH, RIF, EMB & PZA are all 'Sensitive'
		UPDATE dbo.ReusableNotification SET
			DrugResistanceProfile = 'Sensitive to first line'
		WHERE DrugResistanceProfile IS NULL
			AND INH = 'Sensitive'
			AND RIF = 'Sensitive'
			AND EMB = 'Sensitive'
			AND PZA = 'Sensitive'

		-- 6. Notification does not have culture positive confirmation
		UPDATE dbo.ReusableNotification SET
			DrugResistanceProfile = 'No result'
		WHERE DrugResistanceProfile IS NULL
			AND CulturePositive != 'Yes'

		-- 7. In other words, the notification either has no results or has results which are 'Failed' or 'Unknown', and/or a few stray 'Sensitive' records
		UPDATE dbo.ReusableNotification SET
			DrugResistanceProfile = 'No result'
		WHERE DrugResistanceProfile IS NULL
			AND (
					   (INH = 'No result' OR INH = 'Unknown')
					OR (RIF = 'No result' OR RIF = 'Unknown')
					OR (EMB = 'No result' OR EMB = 'Unknown')
					OR (PZA = 'No result' OR PZA = 'Unknown')
				)

		-- 9. An error has occurred
		UPDATE dbo.ReusableNotification SET
			DrugResistanceProfile = 'Error: Invalid value'
		WHERE DrugResistanceProfile IS NULL
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
