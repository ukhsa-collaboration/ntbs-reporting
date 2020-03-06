CREATE PROCEDURE [dbo].[uspGenerateReusableCreateDate]
	
AS
	
	UPDATE [dbo].ReusableNotification
		SET RecordCreateDate = n.AuditCreate
		FROM [$(ETS)].[dbo].[Notification] n
			INNER JOIN [dbo].ReusableNotification rn ON rn.EtsId = n.LegacyId
		WHERE rn.LtbrId IS NULL
		

	UPDATE [dbo].ReusableNotification
		SET RecordCreateDate = Q1.MinDate
	FROM dbo.ReusableNotification rn
		INNER JOIN (SELECT n.LegacyId, DATEADD(day,-3,MIN(el.AuditDateTime)) as MinDate
        FROM [$(ETS)].[dbo].[Notification] n
            INNER JOIN [$(ETS)].[dbo].[LTBRImportErrorLog] el ON el.CaseId = n.AuditMigrateId
        WHERE el.[Status] = 'Success'
        GROUP BY n.LegacyId) Q1 on Q1.LegacyId = rn.EtsId
	WHERE rn.LtbrId IS NOT NULL
	

RETURN 0
