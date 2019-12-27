CREATE PROCEDURE [dbo].[uspSpecimenMDRXDR]
	
AS
		--calculate MDR using same rules as R1

		-- 1. Both INH and RIF are set to 'Resistant'
		UPDATE dbo.LabSpecimen SET
			MDR = 'Yes'
		WHERE MDR IS NULL
			AND (ISO = 'Resistant' AND RIF = 'Resistant')

		-- 2. One of INH and RIF (or both) is 'Sensitive'
		UPDATE dbo.LabSpecimen SET
			MDR = 'No'
		WHERE MDR IS NULL
			AND (ISO = 'Sensitive' OR RIF = 'Sensitive')

		-- 3. One of INH and RIF (or both) is 'No result' or 'Unknown'
		-- TODO: Handle other values (New, Awaiting, No result)
		UPDATE dbo.LabSpecimen SET
			MDR = 'No result'
		WHERE MDR IS NULL
			AND (
					   ISO = 'No result' 
					OR RIF = 'No result' 
					OR ISO = 'Unknown' 
					OR RIF = 'Unknown'
					--OR INH = 'Failed' 
					--OR RIF = 'Failed' 
				)

		/*-- 4. An error has occurred
		UPDATE dbo.ReusableNotification SET
			MDR = 'Error: Invalid value'
		WHERE MDR IS NULL*/

		--calculate XDR using same rules as R1

		-- 1. Both QUIN and AMINO are set to 'Resistant'
		UPDATE dbo.LabSpecimen SET
			XDR = 'Yes'
		WHERE XDR IS NULL
			AND (AMINO = 'Resistant' AND QUIN = 'Resistant')

		-- 2. One of QUIN or AMINO (or both) is 'Sensitive'
		UPDATE dbo.LabSpecimen SET
			XDR = 'No'
		WHERE XDR IS NULL
			AND (AMINO = 'Sensitive' OR QUIN = 'Sensitive')

		-- 3. One of AMINO and QUIN (or both) is 'No result' or 'Unknown'
		-- TODO: Handle other values (New, Awaiting, No result)
		UPDATE dbo.LabSpecimen SET
			XDR = 'No result'
		WHERE XDR IS NULL
			AND (
					   AMINO = 'No result' 
					OR QUIN = 'No result' 
					OR AMINO = 'Unknown' 
					OR QUIN = 'Unknown'
					--OR INH = 'Failed' 
					--OR RIF = 'Failed' 
				)

		/*-- 4. An error has occurred
		UPDATE dbo.ReusableNotification SET
			MDR = 'Error: Invalid value'
		WHERE MDR IS NULL*/
RETURN 0
