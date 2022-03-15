CREATE PROCEDURE [dbo].[uspGenerateRejectSpecimenUsers]
AS
BEGIN TRY

	TRUNCATE TABLE [dbo].[RejectSpecimenUsers]

	INSERT INTO [dbo].[RejectSpecimenUsers]
		(Id,
		ReferenceLaboratoryNumber,
		EventType,
		RejectionTime,
		UserDisplayName,
		NotificationId)

	SELECT 
		a.Id			AS Id,
		a.OriginalId	AS ReferenceLaboratoryNumber,
		a.EventType		AS EventType,
		a.AuditDateTime AS RejectionTime,
		u.DisplayName	AS UserDisplayName,
		a.RootId		AS NotificationId

	FROM [$(NTBS_AUDIT)].dbo.AuditLogs a
	JOIN [$(NTBS)].dbo.[User] u on u.Username = a.AuditUser
	WHERE a.EntityType='Specimen' and (a.EventType = 'Unmatch' or a.EventType = 'RejectPotentialMatch')

END TRY
BEGIN CATCH
	THROW
END CATCH
