/***************************************************************************************************
Desc:    This re/calculates the value for the data points BiologicalTherapy,
		Transplantation and OtherImmunoSuppression in Record_CaseData
         for each notification record (every night when the uspGenerate schedule runs).
		 
         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateEtsImmunosuppression] AS
BEGIN TRY
	SET NOCOUNT ON

	UPDATE cd 
	SET
		BiologicalTherapy = 'Yes'
	FROM
		dbo.Record_CaseData cd
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
	WHERE rr.NotificationId IN (SELECT n.LegacyId
								FROM [$(ETS)].dbo.Notification n
								INNER JOIN [$(ETS)].dbo.Comorbidities co ON co.Id = n.ComorbiditiesId
								INNER JOIN [$(ETS)].dbo.ComorbiditiesImmunoStatus cim ON cim.ComorbiditiesId = co.Id
								INNER JOIN [$(ETS)].dbo.Immunosupressionstatus ims ON ims.Id  = cim.ImmunosuppressionStatusId
								WHERE ims.Name = 'Biological therapy (e.g. Anti-TNF-Alpha-Treatment)')
	AND rr.SourceSystem = 'ETS'


	UPDATE cd 
	SET
		Transplantation = 'Yes'
	FROM
		dbo.Record_CaseData cd
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
	WHERE rr.NotificationId IN (SELECT n.LegacyId
								FROM [$(ETS)].dbo.Notification n
								INNER JOIN [$(ETS)].dbo.Comorbidities co ON co.Id = n.ComorbiditiesId
								INNER JOIN [$(ETS)].dbo.ComorbiditiesImmunoStatus cim ON cim.ComorbiditiesId = co.Id
								INNER JOIN [$(ETS)].dbo.Immunosupressionstatus ims ON ims.Id  = cim.ImmunosuppressionStatusId
								WHERE ims.Name = 'Transplantation')
	AND rr.SourceSystem = 'ETS'

	UPDATE cd 
	SET
		OtherImmunoSuppression = 'Yes'
	FROM
		dbo.Record_CaseData cd
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId
	WHERE rr.NotificationId IN (SELECT n.LegacyId
								FROM [$(ETS)].dbo.Notification n
								INNER JOIN [$(ETS)].dbo.Comorbidities co ON co.Id = n.ComorbiditiesId
								INNER JOIN [$(ETS)].dbo.ComorbiditiesImmunoStatus cim ON cim.ComorbiditiesId = co.Id
								INNER JOIN [$(ETS)].dbo.Immunosupressionstatus ims ON ims.Id  = cim.ImmunosuppressionStatusId
								WHERE ims.Name = 'Other')
	AND rr.SourceSystem = 'ETS'

END TRY
BEGIN CATCH
	THROW
END CATCH
