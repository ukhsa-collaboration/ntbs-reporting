CREATE PROCEDURE [dbo].[uspUpdateNotificationClusterMatchWithNtbsId]
(
	@EtsNotificationId INT,
	@NtbsNotificationId INT
)
AS
	BEGIN TRY
		UPDATE NotificationClusterMatch SET NotificationId=@NtbsNotificationId WHERE NotificationId=@EtsNotificationId;
	END TRY
	BEGIN CATCH
	END CATCH