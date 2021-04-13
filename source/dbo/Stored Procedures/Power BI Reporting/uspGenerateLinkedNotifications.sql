/*
	Provide a list of all notifications related to the ones which are in the Record Register
	This will include notifications which themselves are *not* in the Record Register, as too old
*/

CREATE PROCEDURE [dbo].[uspGenerateLinkedNotifications]
AS
BEGIN TRY	
	WITH GroupedNtbsNotifications AS
	(SELECT GroupId, n.NotificationId 
	FROM [$(NTBS)].[dbo].[Notification] n
	WHERE GroupId IS NOT NULL),

	NtbsGroupings AS
	(SELECT n.NotificationId, rr.SourceSystem, STRING_AGG(g.NotificationId, ', ') AS LinkedNotifications 
	FROM [$(NTBS)].[dbo].[Notification] n
		INNER JOIN GroupedNtbsNotifications g ON g.GroupId = n.groupId and g.NotificationId != n.NotificationId
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = n.NotificationId AND rr.SourceSystem = 'NTBS'
	GROUP BY n.NotificationId, rr.SourceSystem),

	GroupedEtsNotifications AS
	(SELECT GroupId, EtsId 
	FROM [$(migration)].[dbo].[EtsGroupingsAudited] ga
	WHERE GroupId IS NOT NULL),

	EtsGroupings AS
	(SELECT g1.EtsId, rr.SourceSystem, STRING_AGG(g2.EtsId, ', ') AS LinkedNotifications 
	FROM [$(migration)].[dbo].[EtsGroupingsAudited] g1
		INNER JOIN GroupedEtsNotifications g2 ON g2.GroupId = g1.GroupId and g2.EtsId != g1.EtsId
		INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = g1.EtsId AND rr.SourceSystem = 'ETS'
	GROUP BY g1.EtsId, rr.SourceSystem),

	AllGroupings AS
	(SELECT * FROM NtbsGroupings
	UNION
	SELECT * FROM EtsGroupings)

	UPDATE cd
	SET 
		LinkedNotifications = a.LinkedNotifications
	FROM
	[dbo].[Record_CaseData] cd
	INNER JOIN AllGroupings a ON a.NotificationId = cd.NotificationId
END TRY
BEGIN CATCH
	THROW
END CATCH

