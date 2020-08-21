/*This function finds the most recent previous linked notification if the given notification has one.
It does not look 'forward' so if there were three notifications A-B-C with C the most recent, if you
ask for the previous ID of B you will get A*/

CREATE FUNCTION [dbo].[ufnGetPreviousId]
(
	@NTBSId int
)
RETURNS INT
AS
BEGIN

	DECLARE @GroupID INT
	DECLARE @NotificationDate DATE
	DECLARE @PreviousId INT = NULL

	SELECT @GroupID = n.GroupId, @NotificationDate = n.NotificationDate
		FROM [$(NTBS)].[dbo].[Notification] n
		WHERE n.NotificationId = @NTBSId

	IF @GroupID IS NOT NULL
		BEGIN

			SELECT TOP(1) @PreviousId = NotificationId FROM [$(NTBS)].[dbo].[Notification] n
				WHERE n.GroupId = @GroupID
				AND n.NotificationDate < @NotificationDate
				AND n.NotificationStatus IN ('Closed', 'Notified')
				ORDER BY n.NotificationDate
		END
	

	RETURN @PreviousId
END
