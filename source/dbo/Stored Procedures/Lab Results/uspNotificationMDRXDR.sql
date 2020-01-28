CREATE PROCEDURE [dbo].[uspNotificationMDRXDR]
	
AS
		--calculate MDR using same rules as R1

		-- 1. Both INH and RIF are set to 'Resistant'
		UPDATE [dbo].CultureAndResistanceSummary SET
			MDR = 'Yes'
		WHERE MDR IS NULL
			AND (INH = 'Resistant' AND RIF = 'Resistant')

		-- 2. One of INH and RIF (or both) is 'Sensitive'
		UPDATE [dbo].CultureAndResistanceSummary SET
			MDR = 'No'
		WHERE MDR IS NULL
			AND (INH = 'Sensitive' OR RIF = 'Sensitive')

		-- 3. One of INH and RIF (or both) is 'No result' or 'Unknown'
		
		UPDATE [dbo].CultureAndResistanceSummary SET
			MDR = 'No result'
		WHERE MDR IS NULL
			AND (
					   INH = 'No result' 
					OR RIF = 'No result' 
					OR INH = 'Unknown' 
					OR RIF = 'Unknown'
				)

		--calculate XDR using same rules as R1

		-- 1. Both QUIN and AMINO are set to 'Resistant'
		UPDATE [dbo].CultureAndResistanceSummary SET
			XDR = 'Yes'
		WHERE XDR IS NULL
			AND (AMINO = 'Resistant' AND QUIN = 'Resistant')

		-- 2. One of QUIN or AMINO (or both) is 'Sensitive'
		UPDATE [dbo].CultureAndResistanceSummary SET
			XDR = 'No'
		WHERE XDR IS NULL
			AND (AMINO = 'Sensitive' OR QUIN = 'Sensitive')

		-- 3. One of AMINO and QUIN (or both) is 'No result' or 'Unknown'
		UPDATE [dbo].CultureAndResistanceSummary SET
			XDR = 'No result'
		WHERE XDR IS NULL
			AND (
					   AMINO = 'No result' 
					OR QUIN = 'No result' 
					OR AMINO = 'Unknown' 
					OR QUIN = 'Unknown'
				)

RETURN 0
