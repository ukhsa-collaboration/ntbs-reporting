/***************************************************************************************************
Desc:	This populates a series of tables which are the basis of the Power BI reports for NTBS
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReportingRecords]
AS

SET NOCOUNT ON

BEGIN TRY
	TRUNCATE TABLE [dbo].[RecordRegister]
	TRUNCATE TABLE [dbo].[Record_PersonalDetails]
	TRUNCATE TABLE [dbo].[Record_CaseData]
	TRUNCATE TABLE [dbo].[Record_LegacyExtract]

	EXEC [dbo].[uspPopulateLookupTables]

	DECLARE @IncludeNTBS BIT = (SELECT TOP(1) IncludeNTBS FROM [dbo].[ReportingFeatureFlags]);
	DECLARE @IncludeETS BIT = (SELECT TOP(1) IncludeETS FROM [dbo].[ReportingFeatureFlags]);
	
	--first create a list of all the notification which should be in the record register
	--then perform a lookup to get the residence and treatment phec codes
	WITH NotificationsToLookup
	AS
		(SELECT
			n.LegacyId                                                  AS NotificationId				 
			,'ETS'														AS SourceSystem	
			,CONVERT(DATE, n.NotificationDate)                          AS NotificationDate
			,CASE WHEN n.DenotificationId IS NOT NULL THEN 1 ELSE 0 END	AS Denotified
			,tbh.TB_Service_Code										AS TBServiceCode
			,REPLACE(po.Pcd2, ' ', '')									AS Postcode
		FROM  [$(ETS)].dbo.[Notification] n
			LEFT OUTER JOIN [$(ETS)].dbo.Patient p ON p.Id = n.PatientId
			LEFT OUTER JOIN [$(ETS)].dbo.[Address] a ON a.Id = n.AddressId
			LEFT OUTER JOIN [$(ETS)].dbo.Postcode po ON po.Id = a.PostcodeId
			LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = n.HospitalId
			LEFT OUTER JOIN [$(NTBS)].[dbo].[Notification] ntbs ON ntbs.ETSID = n.LegacyId			
		WHERE n.Submitted = 1
			AND n.AuditDelete IS NULL
			--record is not already in NTBS
			AND ntbs.NotificationId IS NULL
			--only include ETS records if the feature flags say we should
			AND @IncludeETS = 1
		UNION
		SELECT
			n.NotificationId											AS NotificationId
			,'NTBS'														AS SourceSystem
			,CONVERT(DATE, n.NotificationDate)							AS NotificationDate
			,CASE WHEN n.NotificationStatus = 'Denotified' 
				THEN 1 ELSE 0 END										AS Denotified
			,hd.TBServiceCode											AS TBServiceCode
			,p.PostcodeToLookup											AS Postcode
		FROM [$(NTBS)].[dbo].[Notification] n
			LEFT OUTER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = n.NotificationId
			LEFT OUTER JOIN [$(NTBS)].[dbo].[Patients] p on p.NotificationId = n.NotificationId
		WHERE n.NotificationStatus NOT IN ('Draft', 'Deleted')
			--only include NTBS records if the feature flags say we should
			AND @IncludeNTBS = 1)

		INSERT INTO RecordRegister ([NotificationId]
			,[SourceSystem]
			,[NotificationDate]
			,[Denotified]
			,[TBServiceCode]
			,[LocalAuthorityCode]
			,[TreatmentPhecCode]
			,[ResidencePhecCode]
			,[ClusterId])
		SELECT 
			ntl.NotificationId, 
			ntl.SourceSystem, 
			ntl.NotificationDate, 
			ntl.Denotified, 
			ntl.TBServiceCode,
			reside.LA_Code,
			treat.PHEC_Code AS TreatmentPhec,
			reside.PHEC_Code AS ResidencePhec, 
			cluster.ClusterId
		FROM NotificationsToLookup ntl
			LEFT OUTER JOIN [dbo].[NotificationClusterMatch] cluster ON cluster.NotificationId = ntl.NotificationId  
			LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].dbo.Reduced_Postcode_file r ON r.Pcode = ntl.Postcode
			LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].dbo.LA_to_PHEC reside ON reside.LA_Code = r.LA_Code
			LEFT OUTER JOIN [$(NTBS_R1_Geography_Staging)].dbo.TB_Service_to_PHEC treat  ON treat.TB_Service_Code = ntl.TBServiceCode
		WHERE (cluster.ClusterId IS NOT NULL OR YEAR(ntl.NotificationDate) IN (SELECT NotificationYear FROM vwNotificationYear))

		--then populate the personal details table for NTBS records

	INSERT INTO [dbo].[Record_PersonalDetails]
		(NotificationId
		,NhsNumber
		,GivenName
		,FamilyName
		,DateOfBirth
		,PostcodeToLookup
		,Postcode)
	SELECT
		rr.NotificationId								AS NotificationId
		,p.NhsNumber									AS NhsNumber
		,p.GivenName									AS Forename
		,p.FamilyName									AS Surname
		,CONVERT(DATE, p.Dob) 							AS DateOfBirth
		,p.PostcodeToLookup								AS PostcodeToLookup
		,p.PostcodeToLookup								AS Postcode --this will later be reformatted if valid
	FROM
		[dbo].[RecordRegister] rr
		INNER JOIN [$(NTBS)].[dbo].[Patients] p ON p.NotificationId = rr.NotificationId
	WHERE rr.SourceSystem = 'NTBS'

	--and for ETS records

	INSERT INTO [dbo].[Record_PersonalDetails]
		(NotificationId
		,NhsNumber
		,GivenName
		,FamilyName
		,DateOfBirth
		,PostcodeToLookup
		,Postcode)
	SELECT
		rr.NotificationId								AS NotificationId
		,p.NhsNumber                                    AS NhsNumber
		,p.Forename                                     AS GivenName
		,p.Surname                                      AS FamilyName
		,CONVERT(DATE, p.DateOfBirth)                   AS DateOfBirth
		,REPLACE(po.Pcd2, ' ', '')						AS PostcodeToLookup
		,po.Pcd2										AS Postcode --this will later be reformatted if valid
	FROM
		[dbo].[RecordRegister] rr
		INNER JOIN [$(ETS)].[dbo].[Notification] n ON n.LegacyId = rr.NotificationId
		INNER JOIN [$(ETS)].[dbo].[Patient] p ON p.Id = n.PatientId
		LEFT OUTER JOIN [$(ETS)].[dbo].[Address] a ON a.Id = n.AddressId
		LEFT OUTER JOIN [$(ETS)].[dbo].[Postcode] po ON po.Id = a.PostcodeId
	WHERE rr.SourceSystem = 'ETS'

	--now create a standardised postcode where possible
	EXEC [dbo].[uspUpdateRecordPostcode]
		
	--now populate case data
	EXEC [dbo].[uspGenerateReportingCaseData]

	--and legacy data
	EXEC [dbo].[uspGenerateReportingLegacyExtract]


		
END TRY
BEGIN CATCH
	THROW
END CATCH