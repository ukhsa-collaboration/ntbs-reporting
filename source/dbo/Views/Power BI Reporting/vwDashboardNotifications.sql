--this view supports the 'NTBS dashboard' report which shows users their cases which do not yet have a final treatment outcome 
--applied to them, as well as notifications with open alerts, This may include cases
--not yet in their service/region but where this is an open transfer request.  This may also include cases which aren't ordinarily
--in the reporting service, i.e. drafts and records which are outside the usual time frame. For these, outcome values are not readily available
--as they are recalculated during the nightly load into the reporting service.

CREATE VIEW [dbo].[vwDashboardNotifications]
	AS 

	WITH NotificationsInScope AS
	(
		SELECT DISTINCT NotificationId 
		FROM [dbo].[vwAlert] WHERE AlertStatus = 'Open'
		UNION
		SELECT DISTINCT cd.NotificationId
		FROM [dbo].[Record_CaseData] cd
			INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = cd.NotificationId AND rr.Denotified = 0 AND SourceSystem = 'NTBS'
		WHERE cd.LastRecordedTreatmentOutcomeDescriptive IN ('No outcome recorded', 'Not evaluated - still on treatment') 
	)
	

	SELECT DISTINCT
		ns.NotificationId AS 'Notification ID'
		,n.NotificationDate AS 'Notification date'
		,u.DisplayName AS 'Case manager'
		,tbs.[Code] AS 'TB service code'
		,tbs.[Name] AS 'TB Service name'
		,h.[Name] AS 'Hospital'
		,clinical.DiagnosisDate AS 'Diagnosis date'
		,clinical.TreatmentStartDate AS 'Start of treatment date'
		--we will not recalculate outcomes for cases not in the reporting service
		,cd.TreatmentOutcome12monthsDescriptive AS '12 month treatment outcome'
		,cd.TreatmentOutcome24monthsDescriptive AS '24 month treatment outcome'
		,cd.TreatmentOutcome36monthsDescriptive AS '36 month treatment outcome'
		,cd.LastRecordedTreatmentOutcomeDescriptive AS 'Last recorded treatment outcome'
		,CASE 
			WHEN n.NotificationStatus = 'Draft' THEN 'Draft'
			WHEN cd.NotificationId IS NULL THEN 'Old'
		 END AS 'LimitedDetailsReason'
		,CASE 
			WHEN overdueOutcome.NotificationId IS NOT NULL THEN 'Overdue'
			WHEN DATEADD(DAY, -30, DATEADD(YEAR, 1, o.NotificationStartDate)) < GETUTCDATE() AND cd.TreatmentOutcome12months = 'No outcome recorded' THEN 'Nearly due'
			WHEN DATEADD(DAY, -30, DATEADD(YEAR, 2, o.NotificationStartDate)) < GETUTCDATE() AND cd.TreatmentOutcome24months = 'No outcome recorded' THEN 'Nearly due'
			WHEN DATEADD(DAY, -30, DATEADD(YEAR, 3, o.NotificationStartDate)) < GETUTCDATE() AND cd.TreatmentOutcome36months = 'No outcome recorded' THEN 'Nearly due'
		END AS 'OutcomeStatus'
		,openTransfer.AlertTBServiceCode AS 'Transfer TB service code'
		,tbsp.PHECCode AS 'Transfer region code'
		,tbs.PHECCode AS 'Treatment region code'
		,la.PHECCode AS 'Residence region code'
		FROM NotificationsInScope ns
			LEFT OUTER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = ns.NotificationId
			LEFT OUTER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = ns.NotificationId
			LEFT OUTER JOIN [$(NTBS)].[dbo].[User] u ON u.Id = hd.CaseManagerId
			LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[TbService] tbs ON tbs.Code = hd.TBServiceCode
			LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[Hospital] h ON h.HospitalId = hd.HospitalId
			LEFT OUTER JOIN [$(NTBS)].[dbo].[ClinicalDetails] clinical ON clinical.NotificationId = ns.NotificationId
			LEFT OUTER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = ns.NotificationId
			LEFT OUTER JOIN [dbo].[Outcome] o ON o.NotificationId = cd.NotificationId
			LEFT OUTER JOIN [dbo].[vwAlert] overdueOutcome ON overdueOutcome.NotificationId = ns.NotificationId AND overdueOutcome.AlertType LIKE '%DataQualityTreatmentOutcome%'
			LEFT OUTER JOIN [dbo].[vwAlert] openTransfer ON openTransfer.NotificationId = ns.NotificationId AND openTransfer.AlertType LIKE '%TransferRequest%' AND openTransfer.AlertStatus = 'Open'
			LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[TbService] tbsp ON tbsp.[Code] = openTransfer.AlertTBServiceCode
			LEFT OUTER JOIN [$(NTBS)].[dbo].[Patients] p ON p.NotificationId = ns.NotificationId
			LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[PostcodeLookup] pl ON pl.Postcode = p.PostcodeToLookup
			LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[LocalAuthorityToPHEC] la ON la.LocalAuthorityCode = pl.LocalAuthorityCode
			
	