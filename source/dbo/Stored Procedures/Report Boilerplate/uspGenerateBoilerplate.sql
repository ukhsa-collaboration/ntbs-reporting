/***************************************************************************************************
Desc:    This pre-calculates the figures for the "Boilerplate" report for performance reasons
         (this is part of the re-generation schedule every night).


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateBoilerplate] AS
	BEGIN TRY
		SET NOCOUNT ON

		-- Reset
		DELETE FROM dbo.Boilerplate

		-- Seed table with all (valid) notifications to consider
		INSERT INTO dbo.Boilerplate (NotificationId)
			SELECT
				NotificationId
			FROM dbo.ReusableNotification WITH (NOLOCK)

		-- Boilerplate: Replace this random calculation by something you want to pre-calculate
		UPDATE dbo.Boilerplate SET
			BoilerplateCalculationNo1 = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM ReusableNotification WITH (NOLOCK)
								 WHERE UkBorn = 'Yes')

		-- Boilerplate: You may want to do an alternative calculation for all remaining notifications
		UPDATE dbo.Boilerplate SET
			BoilerplateCalculationNo1 = 0
		WHERE BoilerplateCalculationNo1 IS NULL
			AND NotificationId IN (SELECT NotificationId
								 FROM ReusableNotification WITH (NOLOCK)
								 WHERE (UkBorn != 'Yes' OR UkBorn IS NULL))

		-- Boilerplate: Replace this random calculation by something you want to pre-calculate
		UPDATE dbo.Boilerplate SET
			BoilerplateCalculationNo2 = 1
		WHERE NotificationId IN (SELECT NotificationId
								 FROM ReusableNotification WITH (NOLOCK)
								 WHERE Age <= 40)

		-- Boilerplate: You may want to do an alternative calculation for all remaining notifications
		UPDATE dbo.Boilerplate SET
			BoilerplateCalculationNo2 = 0
		WHERE BoilerplateCalculationNo2 IS NULL
			AND NotificationId IN (SELECT NotificationId
								 FROM ReusableNotification WITH (NOLOCK)
								 WHERE (Age > 40 OR Age IS NULL))
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
