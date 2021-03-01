CREATE PROCEDURE [dbo].[uspUpdateNotificationClusterMatchWithNtbsId]
(
	@EtsNotificationId INT,
	@NtbsNotificationId INT
)
AS
	BEGIN TRY
		-- If the ETS ID is not already in the NotificationClusterMatch table then nothing will be updated.
		-- This is the desired behaviour as in this case either the Notification does not belong to a cluster,
		-- or the table has already been updated to use the NTBS ID instead of the ETS ID.
		UPDATE NotificationClusterMatch SET NotificationId=@NtbsNotificationId WHERE NotificationId=@EtsNotificationId;
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH