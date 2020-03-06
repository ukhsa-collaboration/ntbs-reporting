CREATE PROCEDURE [dbo].[uspGenerateReusableCreateDate]
	
AS
	
	UPDATE [dbo].ReusableNotification
		SET RecordCreateDate = n.AuditCreate
		FROM [$(ETS)].[dbo].[Notification] n
			INNER JOIN [dbo].ReusableNotification rn ON rn.EtsId = n.LegacyId
		WHERE rn.LtbrId IS NULL
		
	UPDATE [dbo].ReusableNotification
		SET RecordCreateDate = MIN(el.AuditDateTime)
		FROM [$(ETS)].[dbo].[Notification] n
			INNER JOIN [$(ETS)].[dbo].[LTBRImportErrorLog] el ON el.CaseId = n.AuditMigrateId
			INNER JOIN [dbo].ReusableNotification rn ON rn.EtsId = n.LegacyId
		WHERE el.[Status] = 'Success'
		AND rn.LtbrId IS NOT NULL


	SELECT  MIN(el.AuditDateTime) FROM 
		[$(ETS)].[dbo].[Notification] n
		INNER JOIN [$(ETS)].[dbo].[LTBRImportErrorLog] el ON el.CaseId = n.AuditMigrateId


RETURN 0
