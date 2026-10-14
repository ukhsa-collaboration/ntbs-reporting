CREATE PROCEDURE [LTBI].[uspGenerateLTBILineList]

AS


BEGIN TRY	

SELECT * into #Geography FROM (
SELECT   
    lp.PatID																		AS PatID,
	ICB.ICBCodeH																	AS ICBCodeH,
    ICB.ICBCode																	    AS ICBCode,
	ICB.ICBName																		AS ICBName,
    SICB.SICBCodeH                                                                  AS SICBCodeH,
    SICB.SICBCode                                                                   AS SICBCode,
    SICB.SICBName                                                                   AS SICBName,
	 COALESCE(SICB.SICBCodeH,SICBX.SICBCodeH)                                        AS SICBCodeHCleaned,
    COALESCE(SICB.SICBCode,SICBX.SICBCode)                                          AS SICBCodeCleaned,
   COALESCE(SICB.SICBName,SICBX.SICBName)                                          AS SICBNameCleaned, 
       NULLIF(CONCAT_WS(', ',
        NULLIF(TRIM(a.AddrLine1), ''),
        NULLIF(TRIM(a.AddrLine2), ''),
        NULLIF(TRIM(a.AddrTownCity), ''),
        NULLIF(TRIM(a.AddrCnty), '')
		),'')																		AS [Address],
	a.AddrPcodeNormalised													AS Postcode,
SortGeog = ROW_NUMBER() OVER (PARTITION BY lp.PatID ORDER BY ICB.[ICBCode])
  FROM [$(NTBS)].[LTBI].[LTBIPatient] lp WITH (NOLOCK)
  INNER JOIN [$(NTBS)].[LTBIReferenceData].LookICB ICB on ICB.ICBId = lp.PatICB
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].LookSICB SICB on SICB.SICBId = lp.PatSICB 
  INNER JOIN [$(NTBS)].[LTBI].[Address] a WITH (NOLOCK) on a.AddrId = lp.PatLastKnownAddrId
 LEFT JOIN [$(NTBS)].[LTBIReferenceData].[ICBPostCodeXRef] icbx on icbx.PostCode = a.AddrPcodeNormalised
 LEFT JOIN [$(NTBS)].[LTBIReferenceData].LookSICB SICBX on SICBX.SICBCode = icbx.SICBCode
 ) a where SortGeog = 1

 CREATE CLUSTERED INDEX IX_#Geography_PatID ON #Geography(PatID)

SELECT   
    lp.PatID																		AS PatID,
	g.ICBCodeH																		AS ICBCodeH,
    g.ICBCode																	    AS ICBCode,
	g.ICBName																		AS ICBName,
    g.SICBCodeH																		AS SICBCodeH,
    g.SICBCode																		AS SICBCode,
    g.SICBName																		AS SICBName,
	g.SICBCodeHCleaned																AS SICBCodeHCleaned,
    g.SICBCodeCleaned																AS SICBCodeCleaned,
    g.SICBNameCleaned																AS SICBNameCleaned,
    g.[Address]																		AS [Address],
	g.Postcode																		AS Postcode,

	lp.[PatLastKnownHomeTelNo]														AS HomeTelephoneNumber,
    lp.[PatLastKnownMobTelNo]														AS MobileTelephoneNumber,
    lp.[PatLastKnownEmailAddr]														AS EmailAddress,


    CASE    WHEN PatUKEntDay IS NULL AND PatUKEntMonth IS NULL THEN 'Year'
            WHEN PatUKEntDay IS NULL AND PatUKEntMonth IS NOT NULL THEN 'Month'
            WHEN PatUKEntDay IS NOT NULL THEN 'Day' END                             AS UKEntryDatePrecision,

srce.RecSrceName                                                                    AS RecordSource,
'$(NTBS_URL)' + 
	'LTBI/PatientRecord/Overview?PatientId=' + 
	CAST(lp.[PatID] AS varchar(10))													AS [LTBIURL],
lp.PatDateLastUpdate                                                                AS DateLastUpdated,
SortId = ROW_NUMBER() OVER (PARTITION BY lp.PatID ORDER BY g.[ICBCode])

into #t

  FROM [$(NTBS)].[LTBI].[LTBIPatient] lp WITH (NOLOCK)
  INNER JOIN #Geography g on g.PatID = lp.PatID
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].[LookRecSrce] srce on srce.RecSrceId = lp.PatRecSrceId

  TRUNCATE TABLE [LTBI].[LTBILineList];

INSERT INTO [LTBI].[LTBILineList]
(
[PatID]
,[ICBCodeH]
,[ICBCode]
,[ICBName]
,[SICBCodeH]
,[SICBCode]
,[SICBName]
,[SICBCodeHCleaned]
,[SICBCodeCleaned]
,[SICBNameCleaned]
,[NHSNumber]
,[Forename]
,[Surname]
,[DateOfBirth]
,[Sex]
,[Address]
,[Postcode]
,[HomeTelephoneNumber]
,[MobileTelephoneNumber]
,[EmailAddress]
,[GPCode]
,[GPPracticeName]
,[CountryOfBirth]
,[Ethnicity]
,[UKEntryDay]
,[UKEntryMonth]
,[UKEntryYear]
,[UKEntryDate]
,[UKEntryDatePrecision]
,[CountryofTravel]
,[SymptomsindicativeofTB]
,[PreviousactiveTB]
,[PreviouslatentTB]
,[DateofIGRAtestfirstinvitation]
,[IGRAtestfirstinvitationmethod]
,[DateofIGRAtestsecondinvitation]
,[IGRAtestsecondinvitationmethod]
,[DateofIGRAtestthirdinvitation]
,[IGRAtestthirdinvitationmethod]
,[Testaccepted]
,[Testnotaccepteddate]
,[Testnotacceptedreason]
,[Testcarriedoutdate]
,[LTBItestresult]
,[Counsellingreferraldate]
,[Treatmentreferraldate]
,[Treatmentnotreferredreason]
,[TreatmentnotreferredreasonOther]
,[Chestxrayresult]
,[Chestxrayresultdate]
,[AssessedforactiveTB]
,[Treatmentdecisiondate]
,[Patienttreatmentdecision]
,[Treatmentnotacceptedreason]
,[Treatmentdeferredreason]
,[TreatmentdeferredreasonOther]
,[LTBItreatmentstarted]
,[LTBItreatmentstartdate]
,[LTBItreatmentprescribed]
,[LTBItreatmentcompleted]
,[LTBItreatmentcompletiondate]
,[LTBIdatetreatmentstopped]
,[ReasonLTBItreatmentstopped]
,[Adversereactiontomedication]
,[Sideeffects]
,[LTBIURL]
,RecordSource
,DateLastUpdated)

SELECT 
t.[PatID]
,[ICBCodeH]
,t.[ICBCode]
,t.[ICBName]
,t.[SICBCodeH]
,t.[SICBCode]
,t.[SICBName]
,t.[SICBCodeHCleaned]
,t.[SICBCodeCleaned]
,t.[SICBNameCleaned]
,b.NHSNumber AS [NHSNumber]
,b.GivenName AS [Forename]
,b.FamilyName AS [Surname]
,[DateOfBirth]
,b.Gender AS [Sex]
,[Address]
,[Postcode]
,[HomeTelephoneNumber]
,[MobileTelephoneNumber]
,[EmailAddress]
,[GPCode]
,[GPPracticeName]
,[CountryOfBirth]
,[Ethnicity]
,[UKEntryDay]
,[UKEntryMonth]
,[UKEntryYear]
,[UKEntryDate]
,[UKEntryDatePrecision]
,[CountryofTravel]
,[SymptomsindicativeofTB]
,[PreviousactiveTB]
,[PreviouslatentTB]
,[DateofIGRAtestfirstinvitation]
,[IGRAtestfirstinvitationmethod]
,[DateofIGRAtestsecondinvitation]
,[IGRAtestsecondinvitationmethod]
,[DateofIGRAtestthirdinvitation]
,[IGRAtestthirdinvitationmethod]
,[Testaccepted]
,[Testnotaccepteddate]
,[Testnotacceptedreason]
,[Testcarriedoutdate]
,[LTBItestresult]
,[Counsellingreferraldate]
,[Treatmentreferraldate]
,[Treatmentnotreferredreason]
,[TreatmentnotreferredreasonOther]
,[Chestxrayresult]
,[Chestxrayresultdate]
,[AssessedforactiveTB]
,[Treatmentdecisiondate]
,[Patienttreatmentdecision]
,[Treatmentnotacceptedreason]
,[Treatmentdeferredreason]
,[TreatmentdeferredreasonOther]
,[LTBItreatmentstarted]
,[LTBItreatmentstartdate]
,[LTBItreatmentprescribed]
,[LTBItreatmentcompleted]
,[LTBItreatmentcompletiondate]
,[LTBIdatetreatmentstopped]
,[ReasonLTBItreatmentstopped]
,[Adversereactiontomedication]
,[Sideeffects]
,[LTBIURL]
,RecordSource
,DateLastUpdated
      FROM #t t
      INNER JOIN LTBI.LTBIBulkUploadTestingandTreatment b on b.PatID = t.PatID
      WHERE t.SortId = 1;

 

END TRY
BEGIN CATCH
	THROW
END CATCH