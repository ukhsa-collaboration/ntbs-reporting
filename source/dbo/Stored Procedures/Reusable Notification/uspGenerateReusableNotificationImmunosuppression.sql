/***************************************************************************************************
Desc:    This re/calculates the value for the data points ReusableNotification.BiologicalTherapy,
         ReusableNotification.Transplantation and ReusableNotification.OtherImmunoSuppression
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationImmunosuppression] AS
	BEGIN TRY
		SET NOCOUNT ON

		UPDATE dbo.ReusableNotification SET
			BiologicalTherapy = 'Yes'
		WHERE NotificationId IN (SELECT n.Id
								 FROM [$(ETS)].dbo.Notification n
									INNER JOIN [$(ETS)].dbo.Comorbidities co ON co.Id = n.ComorbiditiesId
									INNER JOIN [$(ETS)].dbo.ComorbiditiesImmunoStatus cim ON cim.ComorbiditiesId = co.Id
									INNER JOIN [$(ETS)].dbo.Immunosupressionstatus ims ON ims.Id  = cim.ImmunosuppressionStatusId
								 WHERE ims.Name = 'Biological therapy (e.g. Anti-TNF-Alpha-Treatment)')

		UPDATE dbo.ReusableNotification SET
			Transplantation = 'Yes'
		WHERE NotificationId IN (SELECT n.Id
								 FROM [$(ETS)].dbo.Notification n
									INNER JOIN [$(ETS)].dbo.Comorbidities co ON co.Id = n.ComorbiditiesId
									INNER JOIN [$(ETS)].dbo.ComorbiditiesImmunoStatus cim ON cim.ComorbiditiesId = co.Id
									INNER JOIN [$(ETS)].dbo.Immunosupressionstatus ims ON ims.Id  = cim.ImmunosuppressionStatusId
								 WHERE ims.Name = 'Transplantation')

		UPDATE dbo.ReusableNotification SET
			OtherImmunoSuppression = 'Yes'
		WHERE NotificationId IN (SELECT n.Id
								 FROM [$(ETS)].dbo.Notification n
									INNER JOIN [$(ETS)].dbo.Comorbidities co ON co.Id = n.ComorbiditiesId
									INNER JOIN [$(ETS)].dbo.ComorbiditiesImmunoStatus cim ON cim.ComorbiditiesId = co.Id
									INNER JOIN [$(ETS)].dbo.Immunosupressionstatus ims ON ims.Id  = cim.ImmunosuppressionStatusId
								 WHERE ims.Name = 'Other')

		-- TODO: Log 'Error: Invalid value' has occurred (if any other value in ims.Name)
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
