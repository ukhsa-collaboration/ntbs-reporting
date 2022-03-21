CREATE PROCEDURE [dbo].[uspGenerateRejectedSpecimen]
AS
BEGIN TRY

	TRUNCATE TABLE [dbo].[RejectedSpecimen]

	INSERT INTO [dbo].[RejectedSpecimen]
		(Id,
		ReferenceLaboratoryNumber,
		EventType,
		RejectionDate,
		UserDisplayName,
		NotificationId)

	SELECT 
		a.Id			AS Id,
		a.OriginalId	AS ReferenceLaboratoryNumber,
		a.EventType		AS EventType,
		a.AuditDateTime AS RejectionDate,
		u.DisplayName	AS UserDisplayName,
		a.RootId		AS NotificationId

	FROM [$(NTBS_AUDIT)].dbo.AuditLogs a
	JOIN [$(NTBS)].dbo.[User] u on u.Username = a.AuditUser
	WHERE a.EntityType='Specimen' and (a.EventType = 'Unmatch' or a.EventType = 'RejectPotentialMatch')

END TRY
BEGIN CATCH
	THROW
END CATCH
