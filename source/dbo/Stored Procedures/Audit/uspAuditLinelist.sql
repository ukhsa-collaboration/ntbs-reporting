/***************************************************************************************************
Desc:    This displays a filterable recordset to the National Team that contains logs/audits for 
         each notification record that has been viewed together with information about the user,
		 who has viewed it.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspAuditLineList]
	(
		@DateFrom				DATETIME		=	NULL,
		@DateTo					DATETIME		=	NULL,
		@User					VARCHAR(200)	=	NULL,
		@Group					VARCHAR(200)	=	NULL,
		@ETSID					BIGINT			=	NULL	
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT

		-- Debugging
		-- EXEC master..xp_logevent 60000, @LoginGroups

		IF (@LoginGroups != '###')
		BEGIN
			SELECT
				AccessAuditId	AS 'ID',
				ReportName		AS 'Report name',
				AccessDate		AS 'Date',
				[User]			AS 'User',
				[Group]			AS 'Group',
				NotificationId	AS 'Notification ID',
				EtsId			AS 'ETS ID'
			FROM dbo.AccessAudit
			WHERE AccessDate BETWEEN @DateFrom AND @DateTo
				AND (@ETSID IS NULL OR EtsId = @ETSID)
				AND (@User IS NULL OR [User] = @User)
			ORDER BY AccessAuditId DESC
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
