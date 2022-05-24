--this view supports the 'NTBS dashboard' report which shows users their cases which do not yet have a final treatment outcome 
--applied to them. It's also used to display which notifications have which open alerts, and so may include cases
--not yet in their service/region but where this is an open transfer request

CREATE VIEW [dbo].[vwDashboardNotifications]
	AS 
	SELECT DISTINCT
		cd.NotificationId
		,CASE 
			WHEN overdueOutcome.NotificationId IS NOT NULL THEN 'Overdue'
			WHEN DATEADD(DAY, -30, DATEADD(YEAR, 1, o.NotificationStartDate)) < GETUTCDATE() AND cd.TreatmentOutcome12months = 'No outcome recorded' THEN 'Nearly due'
			WHEN DATEADD(DAY, -30, DATEADD(YEAR, 2, o.NotificationStartDate)) < GETUTCDATE() AND cd.TreatmentOutcome24months = 'No outcome recorded' THEN 'Nearly due'
			WHEN DATEADD(DAY, -30, DATEADD(YEAR, 3, o.NotificationStartDate)) < GETUTCDATE() AND cd.TreatmentOutcome36months = 'No outcome recorded' THEN 'Nearly due'
		END AS 'OutcomeStatus'
		,openTransfer.AlertTBServiceCode
		,tbsp.PHEC_Code AS AlertPhecCode
	FROM [dbo].[Record_CaseData] cd
	INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId AND rr.Denotified = 0
	INNER JOIN [dbo].[Outcome] o ON o.NotificationId = cd.NotificationId
	LEFT OUTER JOIN [dbo].[vwAlert] overdueOutcome ON overdueOutcome.NotificationId = cd.NotificationId AND overdueOutcome.AlertType LIKE '%DataQualityTreatmentOutcome%'
	LEFT OUTER JOIN [dbo].[vwAlert] openTransfer ON openTransfer.NotificationId = cd.NotificationId AND openTransfer.AlertType LIKE '%TransferRequest%' AND openTransfer.AlertStatus = 'Open'
	LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbsp ON tbsp.TB_Service_Code = openTransfer.AlertTBServiceCode
WHERE cd.LastRecordedTreatmentOutcomeDescriptive IN ('No outcome recorded', 'Not evaluated - still on treatment') AND rr.Denotified = 0
