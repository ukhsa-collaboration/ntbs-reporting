CREATE PROCEDURE [LTBI].[uspGenerateEligiblePatientData]
AS

BEGIN TRY

TRUNCATE TABLE [LTBI].[EligiblePatientData];

-- Valid records: use LTBI schema patient/reference data as authoritative source
INSERT INTO [LTBI].[EligiblePatientData]
(
	[Flag4FileName]
	,[IsValidRecord]
	,[PatMatchCritId]
	,PatientMatchCriteriaDescription
	,[PatientId]
	,[InvalidRecordReason]
	,[RecordNo]
	,[TestReason]
	,[SICBCode]
	,SICBHCode
	,[SICBName]
	,[CurrGPCode]
	,[CurrGPName]
	,[CurrGPRegDate]
	,[Flag4GPCode]
	,[Flag4GPName]
	,[Flag4GPRegDate]
	,[NHSNumber]
	,[GivenName]
	,[FamilyName]
	,[Gender]
	,[DOB]
	,[COB]
	,[UKEntDate]
	,[AddrLine1]
	,[AddrLine2]
	,[AddrLine3]
	,[AddrLine4]
	,[FullAddress]
	,[AddrPcode]
	,[TelNo]
	,[MobTelNo]
	,[EmailAddr]
	,[ICBFromSICB]
	,ICBNameFromSICB
	,[ICBFromCurrGP]
	,[ICBFromFlag4GP]
	,[ICBFromPcode]
	,LTBIURL
)
SELECT
	a.[Flag4FileName]
	,CAST(1 AS bit) AS [IsValidRecord]
	,a.[PatMatchCritId]
	,CASE	WHEN pmc.MatchTypeCode = 'S' THEN 'Strong: ' + pmc.[PatMatchCritDesc]
			WHEN pmc.MatchTypeCode = 'W' THEN 'Weak: ' + pmc.[PatMatchCritDesc]
			ELSE pmc.[PatMatchCritDesc] END AS [PatientMatchCriteriaDescription]
	,a.[PatientId]
	,a.[InvalidRecordReason]
	,a.[RecordNo]
	,a.[TestRsn] AS [TestReason]
	,a.SICBCode AS [SICBCode]
	,ls.[SICBCodeH] AS [SICBHCode]
	,ls.[SICBName] AS [SICBName]
	,gpc.[GPCode] AS [CurrGPCode]
	,gpc.[GPName] AS [CurrGPName]
	,a.[CurrGPRegDate]
	,gpf4.[GPCode] AS [Flag4GPCode]
	,gpf4.[GPName] AS [Flag4GPName]
	,ep.[GPRegDate] AS [Flag4GPRegDate]
	,p.[PatNHS] AS [NHSNumber]
	,p.[PatGivenName] AS [GivenName]
	,p.[PatFamilyName] AS [FamilyName]
	,s.[SexDesc] AS [Gender]
	,CAST(p.[PatDOB] AS date) AS [DOB]
	,cob.[CntryName] AS [COB]
	,COALESCE(
		TRY_CONVERT(date, DATEFROMPARTS(p.[PatUKEntYear], NULLIF(p.[PatUKEntMonth], 0), NULLIF(p.[PatUKEntDay], 0))),
		a.[UKEntDate]
	) AS [UKEntDate]
	,a.[AddrLine1] AS [AddrLine1]
	,a.[AddrLine2] AS [AddrLine2]
	,a.[AddrLine3] AS [AddrLine3]
	,a.[AddrLine4] AS [AddrLine4]
	,CONCAT_WS(', ',
		NULLIF(a.[AddrLine1], ''),
		NULLIF(a.[AddrLine2], ''),
		NULLIF(a.[AddrLine3], ''),
		NULLIF(a.[AddrLine4], '')
	) AS [FullAddress]
	,a.[AddrPcode] AS [AddrPcode]
	,a.[TelNo] AS [TelNo]
	,a.[MobTelNo] AS [MobTelNo]
	,a.[EmailAddr]
	,lsICB.[ICBCodeH] AS [ICBFromSICB]
	,lsICB.ICBName AS [ICBNameFromSICB]
	,gpcICB.[ICBCodeH] AS [ICBFromCurrGP]
	,gpf4ICB.[ICBCodeH] AS [ICBFromFlag4GP]
	,pcodeICB.[ICBCodeH] AS [ICBFromPcode]
	,'$(NTBS_URL)' + 'LTBI/PatientRecord/Overview?PatientId=' + CAST(p.[PatID] AS varchar(10)) AS [LTBIURL]
FROM [$(NTBS)].[LTBIBulkLoad].[EligiblePatUploadFileData] a WITH (NOLOCK)
INNER JOIN [$(NTBS)].[LTBI].[IGRATestEligiblePatient] ep WITH (NOLOCK) ON ep.[IGRAEligiblePatId] = a.[PatientId]
	AND ep.[GPRegDate] = a.[Flag4GPRegDate]
INNER JOIN [$(NTBS)].[LTBI].[LTBIPatient] p WITH (NOLOCK) ON p.[PatID] = ep.[IGRAEligiblePatId]
LEFT JOIN [$(NTBS)].[LTBI].[Address] ad WITH (NOLOCK) ON ad.[AddrId] = p.[PatLastKnownAddrId]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookSICB] ls WITH (NOLOCK) ON ls.SICBCode = a.SICBCode
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookICB] lsICB WITH (NOLOCK) ON ls.[ICBId] = lsICB.[ICBId]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookGP] gpc WITH (NOLOCK) ON gpc.GPCode = a.CurrGPCode
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookICB] gpcICB WITH (NOLOCK) ON gpc.[ICBId] = gpcICB.[ICBId]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookGP] gpf4 WITH (NOLOCK) ON gpf4.GPCode = a.Flag4GPCode
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookICB] gpf4ICB WITH (NOLOCK) ON gpf4.[ICBId] = gpf4ICB.[ICBId]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[ICBPostCodeXRef] pcode WITH (NOLOCK) ON pcode.[PostCode] = ad.[AddrPcode]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookICB] pcodeICB WITH (NOLOCK) ON pcodeICB.[ICBCode] = pcode.[ICBCode]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookCountry] cob WITH (NOLOCK) ON cob.[CntryId] = p.[PatCOB]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookSex] s WITH (NOLOCK) ON s.[SexId] = p.[PatSex]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookPatientMatchCriteria] pmc WITH (NOLOCK) ON pmc.[PatMatchCritId] = a.[PatMatchCritId]
WHERE ISNULL(a.[IsValidRecord], 0) = 1;

-- Invalid records: source from bulk-load upload data
INSERT INTO [LTBI].[EligiblePatientData]
(
	[Flag4FileName]
	,[IsValidRecord]
	,[PatMatchCritId]
	,PatientMatchCriteriaDescription
	,[PatientId]
	,[InvalidRecordReason]
	,[RecordNo]
	,[TestReason]
	,[SICBCode]
	,SICBHCode
	,[SICBName]
	,[CurrGPCode]
	,[CurrGPName]
	,[CurrGPRegDate]
	,[Flag4GPCode]
	,[Flag4GPName]
	,[Flag4GPRegDate]
	,[NHSNumber]
	,[GivenName]
	,[FamilyName]
	,[Gender]
	,[DOB]
	,[COB]
	,[UKEntDate]
	,[AddrLine1]
	,[AddrLine2]
	,[AddrLine3]
	,[AddrLine4]
	,[FullAddress]
	,[AddrPcode]
	,[TelNo]
	,[MobTelNo]
	,[EmailAddr]
	,[ICBFromSICB]
	,[ICBNameFromSICB]
	,[ICBFromCurrGP]
	,[ICBFromFlag4GP]
	,[ICBFromPcode]
)
SELECT
	a.[Flag4FileName]
	,a.[IsValidRecord]
	,a.[PatMatchCritId]
	,CASE	WHEN pmc.MatchTypeCode = 'S' THEN 'Strong: ' + pmc.[PatMatchCritDesc]
			WHEN pmc.MatchTypeCode = 'W' THEN 'Weak: ' + pmc.[PatMatchCritDesc]
			ELSE pmc.[PatMatchCritDesc] END AS [PatientMatchCriteriaDescription]
	,a.[PatientId]
	,a.[InvalidRecordReason]
	,a.[RecordNo]
	,a.[TestRsn] AS [TestReason]
	,a.SICBCode AS [SICBCode]
	,ls.[SICBCodeH] AS [SICBHCode]
	,ls.[SICBName] AS [SICBName]
	,a.[CurrGPCode]
	,gpc.[GPName] AS [CurrGPName]
	,a.[CurrGPRegDate]
	,a.[Flag4GPCode]
	,gpf4.[GPName] AS [Flag4GPName]
	,a.[Flag4GPRegDate]
	,a.[NHSNumber]
	,a.[GivenName]
	,a.[FamilyName]
	,a.[Gender]
	,a.[DOB]
	,COALESCE(cob2.[CntryName], a.[COB]) AS [COB]
	,a.[UKEntDate]
	,a.[AddrLine1] AS [AddrLine1]
	,a.[AddrLine2] AS [AddrLine2]
	,a.[AddrLine3] AS [AddrLine3]
	,a.[AddrLine4] AS [AddrLine4]
	,CONCAT_WS(', ',
		NULLIF(a.[AddrLine1], ''),
		NULLIF(a.[AddrLine2], ''),
		NULLIF(a.[AddrLine3], ''),
		NULLIF(a.[AddrLine4], '')
	) AS [FullAddress]
	,a.[AddrPcode] AS [AddrPcode]
	,a.[TelNo] AS [TelNo]
	,a.[MobTelNo] AS [MobTelNo]
	,a.[EmailAddr]
	,lsICB.[ICBCodeH] AS [ICBFromSICB]
	,lsICB.ICBName AS [ICBNameFromSICB]
	,gpcICB.[ICBCodeH] AS [ICBFromCurrGP]
	,gpf4ICB.[ICBCodeH] AS [ICBFromFlag4GP]
	,pcodeICB.[ICBCodeH] AS [ICBFromPcode]
FROM [$(NTBS)].[LTBIBulkLoad].[EligiblePatUploadFileData] a WITH (NOLOCK)
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookSICB] ls WITH (NOLOCK) ON ls.[SICBCode] = a.[SICBCode]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookICB] lsICB WITH (NOLOCK) ON ls.[ICBId] = lsICB.[ICBId]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookGP] gpc WITH (NOLOCK) ON gpc.[GPCode] = a.[CurrGPCode]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookICB] gpcICB WITH (NOLOCK) ON gpc.[ICBId] = gpcICB.[ICBId]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookGP] gpf4 WITH (NOLOCK) ON gpf4.[GPCode] = a.[Flag4GPCode]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookICB] gpf4ICB WITH (NOLOCK) ON gpf4.[ICBId] = gpf4ICB.[ICBId]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[ICBPostCodeXRef] pcode WITH (NOLOCK) ON pcode.[PostCode] = a.[AddrPcode]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookICB] pcodeICB WITH (NOLOCK) ON pcodeICB.[ICBCode] = pcode.[ICBCode]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookCountry] cob2 WITH (NOLOCK) ON cob2.[CntryNHSCode] = a.[COB]
LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookPatientMatchCriteria] pmc WITH (NOLOCK) ON pmc.[PatMatchCritId] = a.[PatMatchCritId]
WHERE ISNULL(a.[IsValidRecord], 0) = 0;

END TRY
BEGIN CATCH
	THROW
END CATCH
