CREATE VIEW [dbo].[vwMissingCohortReviewItems]
	AS
		
	WITH MissingItems AS (SELECT
	cd.NotificationId,

	CASE WHEN cd.Sex = 'Unknown' THEN 'Yes' END AS Sex,
	CASE WHEN cd.EthnicGroup = 'Not stated' THEN 'Yes' END AS EthnicGroup,
	CASE WHEN cd.BirthCountry = 'Unknown' THEN 'Yes' END AS CountryOfBirth,
	CASE WHEN cd.BirthCountry <> 'United Kingdom' AND cd.UkEntryYear IS NULL THEN 'Yes' END AS UkEntry,
	CASE WHEN cd.SputumResult = 'Unknown' THEN 'Yes' END AS SputumResult,
	CASE WHEN car.CulturePositive = 'No' AND cd.CultureSummary = 'No result' THEN 'Yes' END AS CultureResult,
	CASE WHEN car.CulturePositive = 'Yes' AND car.DrugResistanceProfile = 'No result' THEN 'Yes' END AS AntibioticSensitivity,
	CASE WHEN cd.FirstPresentationDate IS NULL AND cd.FirstPresentationSetting IS NULL THEN 'Yes' END AS FirstPresentation,
	CASE WHEN cd.TbServiceReferralReceivedDate IS NULL THEN 'Yes' END AS ReferralReceivedDate,
	CASE WHEN cd.TreatmentEndDate IS NULL THEN 'Yes' END AS TreatmentEndDate,
	CASE WHEN cd.EnhancedCaseManagement IS NULL
		OR cd.EnhancedCaseManagement = 'Unknown'
		OR (cd.EnhancedCaseManagement = 'Yes' AND cd.EnhancedCaseManagementLevel IS NULL) THEN 'Yes' END AS ECM,
	CASE WHEN cd.HivTestOffered IS NULL THEN 'Yes' END AS HIV,
	CASE WHEN cd.DOTOffered IS NULL
		OR cd.DOTOffered = 'Unknown'
		OR (cd.DOTOffered = 'Yes' AND cd.DOTReceived IS NULL) THEN 'Yes' END AS DOT,
	CASE WHEN cd.LastRecordedTreatmentOutcome = 'No outcome recorded' THEN 'Yes' END AS OutcomeRecorded,
	CASE WHEN cd.ChildContactsIdentified IS NULL AND cd.AdultContactsIdentified IS NULL THEN 'Yes' END AS ContactsIdentified,
	CASE WHEN cd.ChildContactsAssessed IS NULL AND cd.AdultContactsAssessed IS NULL THEN 'Yes' END AS ContactsScreened,
	CASE WHEN cd.ChildContactsLTBI IS NULL AND cd.AdultContactsLTBI IS NULL THEN 'Yes' END AS ContactsLTBI,
	CASE WHEN cd.ChildContactsLTBITreat IS NULL AND cd.AdultContactsLTBITreat IS NULL THEN 'Yes' END AS ContactsLTBIStartedTreatment,
	CASE WHEN cd.ChildContactsLTBITreatComplete IS NULL AND cd.AdultContactsLTBITreatComplete IS NULL THEN 'Yes' END AS ContactsLTBICompletedTreatment 
	
	FROM [Record_CaseData] cd
	LEFT JOIN Record_CultureAndResistance car ON car.NotificationId = cd.NotificationId
	JOIN [$(NTBS)].dbo.Notification n ON n.NotificationId = cd.NotificationId)

	SELECT * FROM MissingItems
	WHERE NOT (
		Sex IS NULL AND EthnicGroup IS NULL AND CountryOfBirth IS NULL AND
		SputumResult IS NULL AND CultureResult IS NULL AND AntibioticSensitivity IS NULL AND
		FirstPresentation IS NULL AND ReferralReceivedDate IS NULL AND TreatmentEndDate IS NULL AND ECM IS NULL AND HIV IS NULL AND DOT IS NULL AND
		OutcomeRecorded IS NULL AND ContactsIdentified IS NULL AND ContactsScreened IS NULL AND
		ContactsLTBI IS NULL AND ContactsLTBIStartedTreatment IS NULL AND ContactsLTBICompletedTreatment IS NULL
	)
