CREATE PROCEDURE [dbo].[uspMigrationDuplicateAlerts]
	@MigrationRun INT = NULL
AS
	WITH DuplicatePairs AS
	(
		SELECT DISTINCT
		-- The 'first' notification should be the notification that is included in the migration, if both are included then order by notification date.
		CASE
			WHEN dupmrr.MigrationNotificationId IS NULL OR mrr.NotificationDate <= duplicate.NotificationDate
			THEN mrr.NTBSNotificationId
			ELSE duplicate.NotificationId
		END AS 'FirstNotification',
		CASE
			WHEN dupmrr.MigrationNotificationId IS NULL OR mrr.NotificationDate <= duplicate.NotificationDate
			THEN duplicate.NotificationId
			ELSE mrr.NTBSNotificationId
		END AS 'SecondNotification'
		FROM [dbo].[MigrationRunResults] mrr
			INNER JOIN [$(NTBS)].[dbo].[Alert] a on a.NotificationId = mrr.NTBSNotificationId
			INNER JOIN [$(NTBS)].[dbo].[Notification] duplicate on duplicate.NotificationId = a.DuplicateId
			LEFT JOIN [dbo].[MigrationRunResults] dupmrr ON dupmrr.LegacyETSId = duplicate.ETSID
		WHERE AlertStatus = 'Open'
			AND AlertType = 'DataQualityPotientialDuplicate'
			AND mrr.MigrationRunId = @MigrationRun
	) 
	SELECT
		mrr.MigrationNotificationId													AS 'MigrationNotificationId',
		firstNot.ETSID																AS 'EtsId',
		firstNot.NotificationId														AS 'NtbsId',
		firstNot.NotificationDate													AS 'NotificationDate',
		firstNotTbService.[Name]													AS 'TbService',
		secondNot.NotificationId													AS 'DuplicateNtbsId',
		secondNot.ETSID																AS 'DuplicateEtsId',
		secondNot.NotificationDate													AS 'DuplicateNotificationDate',
		secondNotTbService.[Name]													AS 'DuplicateTbService',
		ABS(DATEDIFF(day, firstNot.NotificationDate, secondNot.NotificationDate))	AS 'DaysBetweenNotifications',
		CASE
			WHEN firstNotP.GivenName = secondNotP.GivenName
				AND firstNotP.FamilyName = secondNotP.FamilyName
				AND firstNotP.NhsNumber = secondNotP.NhsNumber
				AND firstNotP.Dob = secondNotP.Dob
				THEN 'Yes'
			ELSE 'No'
		END																			AS 'DemographicsMatch'
	FROM DuplicatePairs pairs
		LEFT JOIN [dbo].[MigrationRunResults] mrr ON mrr.NTBSNotificationId = pairs.FirstNotification
		LEFT JOIN [$(NTBS)].[dbo].[Notification] firstNot on firstNot.NotificationId = pairs.FirstNotification
		LEFT JOIN [$(NTBS)].[dbo].[Patients] firstNotP on firstNotP.NotificationId = firstNot.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].[HospitalDetails] firstNotHd on firstNotHd.NotificationId = firstNot.NotificationId
		LEFT JOIN [$(NTBS)].[ReferenceData].[TbService] firstNotTbService on firstNotTbService.Code = firstNotHd.TBServiceCode
		LEFT JOIN [$(NTBS)].[dbo].[Notification] secondNot on secondNot.NotificationId = pairs.SecondNotification
		LEFT JOIN [$(NTBS)].[dbo].[Patients] secondNotP on secondNotP.NotificationId = secondNot.NotificationId
		LEFT JOIN [$(NTBS)].[dbo].[HospitalDetails] secondNotHd on secondNotHd.NotificationId = secondNot.NotificationId
		LEFT JOIN [$(NTBS)].[ReferenceData].[TbService] secondNotTbService on secondNotTbService.Code = secondNotHd.TBServiceCode