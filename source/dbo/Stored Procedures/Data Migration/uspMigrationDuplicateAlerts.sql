CREATE PROCEDURE [dbo].[uspMigrationDuplicateAlerts]
	@MigrationRun INT = NULL
AS
	WITH DuplicatePairs AS
	(
		SELECT DISTINCT
		CASE WHEN mrr.NotificationDate < duplicate.NotificationDate THEN mrr.NTBSNotificationId ELSE duplicate.NotificationId END AS 'OriginalNotification',
		CASE WHEN mrr.NotificationDate > duplicate.NotificationDate THEN mrr.NTBSNotificationId ELSE duplicate.NotificationId END AS 'DuplicateNotification'
		FROM [dbo].[MigrationRunResults] mrr
			INNER JOIN [$(NTBS)].[dbo].[Alert] a on a.NotificationId = mrr.NTBSNotificationId
			LEFT JOIN [$(NTBS)].[dbo].[Notification] duplicate on duplicate.NotificationId = a.DuplicateId
		WHERE AlertStatus = 'Open'
			AND AlertType = 'DataQualityPotientialDuplicate'
			AND mrr.MigrationRunId = @MigrationRun
	) 
	SELECT
		mrr.MigrationNotificationId													AS 'MigrationNotificationId',
		original.ETSID																AS 'EtsId',
		original.NotificationId														AS 'NtbsId',
		original.NotificationDate													AS 'NotificationDate',
		originalTbService.[Name]													AS 'TbService',
		duplicate.NotificationId													AS 'DuplicateNtbsId',
		duplicate.ETSID																AS 'DuplicateEtsId',
		duplicate.NotificationDate													AS 'DuplicateNotificationDate',
		duplicateTbService.[Name]													AS 'DuplicateTbService',
		ABS(DATEDIFF(day, original.NotificationDate, duplicate.NotificationDate))	AS 'DaysBetweenNotifications',
		CASE
			WHEN originalp.GivenName = duplicatep.GivenName
				AND originalp.FamilyName = duplicatep.FamilyName
				AND originalp.NhsNumber = duplicatep.NhsNumber
				AND originalp.Dob = duplicatep.Dob
				THEN 'Yes'
			ELSE 'No'
		END																			AS 'DemographicsMatch'
	FROM DuplicatePairs pairs
		LEFT JOIN [dbo].[MigrationRunResults] mrr ON mrr.NTBSNotificationId = pairs.OriginalNotification
		LEFT JOIN [$(NTBS)].[dbo].[Notification] original on original.NotificationId = pairs.OriginalNotification
		LEFT JOIN [$(NTBS)].[dbo].[Patients] originalp on originalp.NotificationId = original.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].[HospitalDetails] originalHd on originalHd.NotificationId = original.NotificationId
		LEFT JOIN [$(NTBS)].[ReferenceData].[TbService] originalTbService on originalTbService.Code = originalHd.TBServiceCode
		LEFT JOIN [$(NTBS)].[dbo].[Notification] duplicate on duplicate.NotificationId = pairs.DuplicateNotification
		LEFT JOIN [$(NTBS)].[dbo].[Patients] duplicatep on duplicatep.NotificationId = duplicate.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].[HospitalDetails] duplicateHd on duplicateHd.NotificationId = duplicate.NotificationId
		LEFT JOIN [$(NTBS)].[ReferenceData].[TbService] duplicateTbService on duplicateTbService.Code = duplicateHd.TBServiceCode