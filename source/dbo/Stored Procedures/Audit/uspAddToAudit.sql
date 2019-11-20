/***************************************************************************************************
Desc:    Every "Line List" needs to call this proc in order to log/audit each notification record
         together with information about the user, who has viewed it.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspAddToAudit]
	(
		@ReportName VARCHAR(50),
		@LoginGroups VARCHAR(500),
		@ReusableNotification ReusableNotificationType READONLY
	)
AS
	BEGIN TRY
		INSERT INTO AccessAudit
			SELECT
				@ReportName,
				GETUTCDATE(),
				SUBSTRING(SUSER_NAME(), CHARINDEX('\', SUSER_NAME()) + 1, LEN(SUSER_NAME())),
				@LoginGroups,
				NotificationId,
				EtsId
			FROM @ReusableNotification
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
