/***************************************************************************************************
Desc:    This report shows all the mappings used when importing records to the Labbase2 database.

Author:  PHE
**************************************************************************************************/

Create PROCEDURE [dbo].[uspNTSReportLabMappings]
		(
			@FieldName			VARCHAR(50)			=	NULL,
			@LabName			VARCHAR(50)			=	NULL
		)
AS
	SET NOCOUNT ON

	-- Debugging
	-- EXEC master..xp_logevent 60000, @ResidenceTreatment

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN


			select [FieldName]
      ,[ETSDisplayCode]
      ,[LabDisplayCode]
      ,[LabName]
      ,dbo.ufnFormatDateConsistently([auditcreate]) as [auditcreate]
      ,[Description] 
			from LabMappings m where 
			m.FieldName = @FieldName and m.LabName = @LabName
			order by FieldName, LabName, ETSDisplayCode
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
GO

