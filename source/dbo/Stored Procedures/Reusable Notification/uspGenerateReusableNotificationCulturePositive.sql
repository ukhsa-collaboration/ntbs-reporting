/***************************************************************************************************
Desc:    This re/calculates the value for the data point ReusableNotification.CulturePositive
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationCulturePositive] AS
	BEGIN TRY
		SET NOCOUNT ON

		-- 1. Notification has no LaboratoryResult records
		UPDATE dbo.ReusableNotification_ETS SET
			CulturePositive = 'No'
		WHERE CulturePositive IS NULL
			AND NotificationId NOT IN (SELECT DISTINCT NotificationId -- You can have multiple lab result records for the same case
										FROM [dbo].[StandardisedETSLaboratoryResult])

		-- 3. Notification has LaboratoryResult records where the OpieID is not null
		UPDATE dbo.ReusableNotification_ETS SET
			CulturePositive = 'Yes'
		WHERE CulturePositive IS NULL
			AND NotificationId IN (SELECT DISTINCT NotificationId -- You can have multiple lab result records for the same case
									FROM [dbo].[StandardisedETSLaboratoryResult]
									WHERE OpieId IS NOT NULL) -- Ignore manually entered lab results

		-- 2. Notification only has LaboratoryResult records where the OpieID is null
		UPDATE dbo.ReusableNotification_ETS SET
			CulturePositive = 'No'
		WHERE CulturePositive IS NULL
			AND NotificationId IN (SELECT DISTINCT NotificationId -- You can have multiple lab result records for the same case
									FROM [dbo].[StandardisedETSLaboratoryResult]
									WHERE OpieId IS NULL) -- Ignore manually entered lab results

		-- 3. An error has occurred
		UPDATE dbo.ReusableNotification_ETS SET
			CulturePositive = 'Error: Invalid value'
		WHERE CulturePositive IS NULL
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
