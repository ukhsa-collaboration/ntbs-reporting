/***************************************************************************************************
Desc:    This pre-calculates the figures for the "Culture And Resistance" report for performance reasons
         (this is part of the re-generation schedule every night).


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateCultureResistance] AS
	BEGIN TRY
		SET NOCOUNT ON

		-- Reset
		TRUNCATE TABLE dbo.CultureResistance

		-- Seed table with all (valid) notifications to consider
		INSERT INTO dbo.CultureResistance (NotificationId)
			SELECT
				NotificationId
			FROM dbo.ReusableNotification

		-- Total records where Culture Positive is set to 'Yes'
		UPDATE dbo.CultureResistance SET
			CulturePositiveCases = 1
		WHERE NotificationId IN (SELECT NotificationId
				 FROM dbo.ReusableNotification WITH (NOLOCK)
				 WHERE CulturePositive = 'Yes')

		-- 1. Drug Resistance Profile is 'No Result' and Culture Positive is not set to 'Yes'
		UPDATE dbo.CultureResistance SET
			NonCulturePositiveCases = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DrugResistanceProfile = 'No Result'
									AND (CulturePositive != 'Yes' OR CulturePositive IS NULL))

		-- 2. Drug Resistance Profile is set to 'No result' and Culture Positive is set to 'Yes'
		UPDATE dbo.CultureResistance SET
			IncompleteDrugResistanceProfile = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DrugResistanceProfile = 'No Result'
									AND CulturePositive = 'Yes')

		-- 3. Drug Resistance Profile is set to 'Sensitive to first line'
		UPDATE dbo.CultureResistance SET
			SensitiveToAll4FirstLineDrugs = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DrugResistanceProfile = 'Sensitive to first line')

		-- 4. Drug Resistance Profile is 'INH Resistant'
		UPDATE dbo.CultureResistance SET
			InhRes = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DrugResistanceProfile = 'INH Resistant')

		-- 5. Drug Resistance Profile is 'INH+RIF Sensitive'
		UPDATE dbo.CultureResistance SET
			Other = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DrugResistanceProfile = 'INH+RIF Sensitive')

		-- 6. Drug Resistance Profile is 'RR/MDR/XDR' and XDR is not Yes
		UPDATE dbo.CultureResistance SET
			MdrRr = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DrugResistanceProfile = 'RR/MDR/XDR'
									AND (XDR != 'Yes' OR XDR IS NULL))

		-- 7. Drug Resistance Profile is 'RR/MDR/XDR' and XDR is Yes
		UPDATE dbo.CultureResistance SET
			Xdr = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM dbo.ReusableNotification WITH (NOLOCK)
								 WHERE DrugResistanceProfile = 'RR/MDR/XDR'
									AND XDR = 'Yes')

		-- 8. An error has occurred, record belongs in Bucket 'Other'
		-- This query captures all notifications that are not part of any of the above buckets yet
		UPDATE dbo.CultureResistance SET
			Other = 1
		WHERE NonCulturePositiveCases = 0
			AND IncompleteDrugResistanceProfile = 0
			AND SensitiveToAll4FirstLineDrugs = 0
			AND InhRes = 0
			AND Other = 0
			AND MdrRr = 0
			AND Xdr = 0
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
