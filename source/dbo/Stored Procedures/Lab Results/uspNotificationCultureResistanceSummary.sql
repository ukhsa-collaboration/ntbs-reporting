CREATE PROCEDURE [dbo].[uspNotificationCultureResistanceSummary]
	
AS
	SET NOCOUNT ON

	BEGIN TRY
		/*This will populate ReusableNotification with fields which give a culture and resistance summary for each notification, built from the
		LabSpecimen summaries which are matched to the notification*/

		
		
		/*CALCULATE CULTURE POSITIVE FIELD. This is determined by presence of at least one matched lab specimen for the notification*/
		UPDATE [dbo].ReusableNotification SET
			CulturePositive = 'Yes' WHERE NotificationId IN (
				SELECT DISTINCT NotificationID FROM dbo.vwConfirmedMatch)

		UPDATE [dbo].ReusableNotification SET
			CulturePositive = 'No' WHERE NotificationId NOT IN (
				SELECT DISTINCT NotificationID FROM dbo.vwConfirmedMatch)

		/*END OF CALCULATE CULTURE POSITIVE FIELD*/
		--TODO: if not culture positive, there is no real point in running the logic on the rest of the fields - just set to 'No result' or blank?


		/*CALCULATE THE SPECIES*/

		--grab the highest ranked species for each notification

		UPDATE [dbo].ReusableNotification SET
			Species = Q2.OrganismName FROM
			--next query links the rank back to the organism name
			(SELECT Q1.NotificationId, o.OrganismName FROM
				--innermost query gets the highest ranked Organism from the matched specimens
				(SELECT DISTINCT vcm.[NotificationID], MIN(o.OrganismId) AS 'MinRank'
				FROM [dbo].[vwConfirmedMatch] vcm
				INNER JOIN [dbo].Organism o on o.OrganismName = vcm.Species
				GROUP BY vcm.[NotificationID]) AS Q1
			INNER JOIN [dbo].Organism o on o.OrganismId = Q1.MinRank) AS Q2
			WHERE Q2.NotificationID = [dbo].ReusableNotification.NotificationId

		UPDATE [dbo].ReusableNotification SET Species = 'No result'
			WHERE Species IS NULL

		/*END OF CALCULATE THE SPECIES*/

		/*CALCULATE EARLIEST SPECIMEN DATE*/

		UPDATE [dbo].ReusableNotification SET
			EarliestSpecimenDate = Q1.MinDate FROM
				(SELECT NotificationID, MIN(SpecimenDate) AS 'MinDate' FROM [dbo].vwConfirmedMatch
				GROUP BY NotificationID) AS Q1
			WHERE Q1.NotificationID = [dbo].ReusableNotification.NotificationId

		/*END OF CALCULATE EARLIEST SPECIMEN DATE*/


		/*CALCULATE EACH OF THE DRUG SENSITIVITY TEST RESULTS IN TURN*/

		EXEC [dbo].uspNotificationSensitivityResult 'INH'
		EXEC [dbo].uspNotificationSensitivityResult 'RIF'
		EXEC [dbo].uspNotificationSensitivityResult 'EMB'
		EXEC [dbo].uspNotificationSensitivityResult 'PZA'
		EXEC [dbo].uspNotificationSensitivityResult 'QUIN'
		EXEC [dbo].uspNotificationSensitivityResult 'AMINO'

		--now calculate the MDR and XDR values. Do this from scratch rather than rely on the specimen values
		--on the off chance one specimen is resistant to ISO and another is resistant to RIF, in which case
		--neither specimen will have had MDR set to 'Yes'
		EXEC [dbo].uspNotificationMDRXDR
		
	
	
		/*CALCULATE DRUG RESISTANCE PROFILE AT THE END - DEPENDS ON THE OTHER VALUES*/

		--1. Set RR/MDR/XDR
		UPDATE [dbo].ReusableNotification SET
			DrugResistanceProfile = 'RR/MDR/XDR' 
			WHERE
				DrugResistanceProfile IS NULL
				AND (MDR = 'Yes' OR RIF = 'Resistant')
			

		--2. Set INH resistant
		UPDATE [dbo].ReusableNotification SET
			DrugResistanceProfile = 'INH resistant' 
			WHERE
				DrugResistanceProfile IS NULL
				AND INH = 'Resistant'

		--3. Set INH + RIF sensitive (ISO and RIF are both 'Sensitive' but one or both of ETHAM and PYR are 'Resistant')
		UPDATE [dbo].ReusableNotification SET
			DrugResistanceProfile = 'INH+RIF sensitive' 
			WHERE
				DrugResistanceProfile IS NULL
				AND
				(INH = 'Sensitive' AND RIF = 'Sensitive') AND (EMB = 'Resistant' OR PZA = 'Resistant')
			

		--4. INH, RIF, EMB & PZA are all 'Sensitive'
		UPDATE [dbo].ReusableNotification SET
			DrugResistanceProfile = 'Sensitive to first line'
			WHERE DrugResistanceProfile IS NULL
				AND (INH = 'Sensitive'
				AND RIF = 'Sensitive'
				AND EMB = 'Sensitive'
				AND PZA = 'Sensitive')

		-- 5. Notification does not have culture positive confirmation
		UPDATE [dbo].ReusableNotification SET
			DrugResistanceProfile = 'No result'
			WHERE DrugResistanceProfile IS NULL
				AND CulturePositive != 'Yes'

		--6. Finally set remaining records to No result
		UPDATE [dbo].ReusableNotification SET
			DrugResistanceProfile = 'No result'
			WHERE DrugResistanceProfile IS NULL


	END TRY
	BEGIN CATCH
		THROW
	END CATCH
