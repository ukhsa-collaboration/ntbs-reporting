CREATE PROCEDURE [LTBI].[uspGenerateTestingandTreatment]
 
AS

BEGIN TRY	

SELECT  
	--ICB.ICBCode							AS ICBCode, 
	lp.PatID																		AS PatID,
	ICB.ICBCodeH																	AS ICBCode,
	ICB.ICBName																		AS ICBName,
    SICB.SICBCodeH                                                                  AS SICBCode,
    SICB.SICBName                                                                   AS SICBName,
	lp.PatNHS																		AS NHSNumber,
	lp.PatGivenName																	AS GivenName,
	lp.PatFamilyName																AS FamilyName,
	CAST(lp.PatDOB AS DATE)															AS DateOfBirth,
	s.SexDesc																		AS Gender,
	a.AddrPcode																		AS PatientPostcode,
	gp.GPCode																		AS GPCode,
    gp.GPName                                                                       AS GPPracticeName,
	cob.CntryName																	AS CountryOfBirth,
	eth.EthDesc																		AS Ethnicity,
	lp.PatUKEntDay																	AS UKEntryDay,
	lp.PatUKEntMonth																AS UKEntryMonth,
	lp.PatUKEntYear																	AS UKEntryYear,
    CASE 
        WHEN lp.PatUKEntYear IS NULL THEN NULL
        WHEN lp.PatUKEntMonth IS NULL THEN CAST(lp.PatUKEntYear	 AS VARCHAR(4))
        WHEN lp.PatUKEntDay IS NULL THEN 
            DATENAME(MONTH, DATEFROMPARTS(lp.PatUKEntYear	, lp.PatUKEntMonth, 1)) 
            + ' ' + CAST(lp.PatUKEntYear	 AS VARCHAR(4))
    ELSE 
        CAST(lp.PatUKEntDay AS VARCHAR(2)) + ' ' +
        DATENAME(MONTH, DATEFROMPARTS(lp.PatUKEntYear, lp.PatUKEntMonth, lp.PatUKEntDay)) 
        + ' ' + CAST(lp.PatUKEntYear AS VARCHAR(4))                                     END AS UKEntryDate,
	cotr.CntryName																	AS CountryofTravel,
	CASE	WHEN PatSignOfActiveTB = 0 THEN 'No' 
			WHEN  PatSignOfActiveTB = 1 THEN 'Yes' 
			ELSE NULL END															AS SymptomsindicativeofTB,
	CASE	WHEN histact.TBHistPatID IS NOT NULL THEN 'Yes' 
			ELSE NULL END															AS PreviousactiveTB,
	CASE	WHEN histlat.TBHistPatID IS NOT NULL THEN 'Yes' 
			ELSE NULL END															AS PreviouslatentTB,
CAST(ti1.IGRATestInviteDate AS DATE) 	 											AS DateofIGRAtestfirstinvitation,
NULLIF(CONCAT_WS(';',
        CASE WHEN ti1.IsLetterMethod = 1 THEN 'Letter' END,
        CASE WHEN ti1.IsTextMethod = 1 THEN 'Text' END,
        CASE WHEN ti1.IsPhoneMethod = 1 THEN 'Phone' END,
        CASE WHEN ti1.IsEmailMethod = 1 THEN 'Email' END,
        CASE WHEN ti1.IsSelfReferralMethod = 1 THEN 'Self Referral' END
    )	,'')																		AS IGRAtestfirstinvitationmethod,
CAST(ti2.IGRATestInviteDate AS DATE)												AS DateofIGRAtestsecondinvitation,
NULLIF(CONCAT_WS(';',
        CASE WHEN ti2.IsLetterMethod = 1 THEN 'Letter' END,
        CASE WHEN ti2.IsTextMethod = 1 THEN 'Text' END,
        CASE WHEN ti2.IsPhoneMethod = 1 THEN 'Phone' END,
        CASE WHEN ti2.IsEmailMethod = 1 THEN 'Email' END,
        CASE WHEN ti2.IsSelfReferralMethod = 1 THEN 'Self Referral' END
    )	,'')																		AS IGRAtestsecondinvitationmethod,
CAST(ti3.IGRATestInviteDate AS DATE)												AS DateofIGRAtestthirdinvitation,
NULLIF(CONCAT_WS(';',
        CASE WHEN ti3.IsLetterMethod = 1 THEN 'Letter' END,
        CASE WHEN ti3.IsTextMethod = 1 THEN 'Text' END,
        CASE WHEN ti3.IsPhoneMethod = 1 THEN 'Phone' END,
        CASE WHEN ti3.IsEmailMethod = 1 THEN 'Email' END,
        CASE WHEN ti3.IsSelfReferralMethod = 1 THEN 'Self Referral' END
    )	,'')																		AS IGRAtestthirdinvitationmethod,	
CASE	WHEN it.IsIGRATestAccept = 1 THEN 'Yes'
		WHEN it.IsIGRATestAccept = 0 THEN 'No' END									AS Testaccepted,
CAST(CASE WHEN it.IsIGRATestAccept = 0 THEN it.IGRADate END	AS DATE)				AS Testnotaccepteddate,
CASE WHEN it.IsIGRATestAccept = 0 THEN clTSTNOAC.DisplayMapping END					AS Testnotacceptedreason,
CAST(CASE WHEN it.IsIGRATestAccept = 1 THEN itr.IGRATestResultDate END AS DATE)		AS Testcarriedoutdate,
CASE WHEN it.IsIGRATestAccept = 1 THEN itr.DisplayMapping END						AS LTBItestresult,
CAST(ir.IGRACounselReferralDate AS DATE)											AS Counsellingreferraldate,
CAST(ir.IGRATreatReferralDate AS DATE)												AS Treatmentreferraldate,
clNoReferRsn.DisplayMapping															AS Treatmentnotreferredreason,
ir.IGRATreatNoReferOthRsnDesc														AS TreatmentnotreferredreasonOther,
tsXRAY.DisplayMapping																AS Chestxrayresult,
CAST(tsXRAY.TBTreatStatDate AS DATE)												AS Chestxrayresultdate,
CASE	WHEN lp.PatAssessedForActiveTB = 0 THEN 'No' 
			WHEN  lp.PatAssessedForActiveTB = 1 THEN 'Yes' 
			ELSE NULL END															AS AssessedforactiveTB,
CAST(cldecision.TBTreatStatDate AS DATE)											AS Treatmentdecisiondate,
cldecision.Patienttreatmentdecision													AS Patienttreatmentdecision,
tnd.Treatmentnotacceptedreason														AS Treatmentnotacceptedreason,
td.DisplayMapping																	AS Treatmentdeferredreason,
td.TBTreatStatNote																	AS TreatmentdeferredreasonOther,
CASE	WHEN tsts.TBTreatStatCode  = 'NOTSTARTTREAT1'   THEN 'No' 
			WHEN  tsts.TBTreatStatCode =  'IGRATREAT5'  THEN 'Yes' 
			ELSE NULL END															AS LTBItreatmentstarted,
CAST(tsts.TBTreatStatDate AS DATE)													AS LTBItreatmentstartdate,
trp.DisplayMapping																	AS LTBItreatmentprescribed,
CASE	WHEN tro.TBTreatStatCode  = 'IGRATREAT3' THEN 'Ongoing' 
		WHEN tro.TBTreatStatCode =  'IGRATREAT4' THEN 'No'
		WHEN tro.TBTreatStatCode =  'IGRATREAT7' THEN 'Yes' 
		ELSE NULL END																AS LTBItreatmentcompleted,
CAST(CASE WHEN tro.TBTreatStatCode = 'IGRATREAT7' 
				THEN tro.TBTreatStatDate END AS DATE)								AS LTBItreatmentcompletiondate,
CAST(CASE WHEN tro.TBTreatStatCode = 'IGRATREAT4' 
				THEN tro.TBTreatStatDate END AS DATE)								AS LTBIdatetreatmentstopped,
trst.DisplayMapping																	AS ReasonLTBItreatmentstopped,
CASE	WHEN adv.TBTreatStatCode  = 'ADVREA0009'   THEN 'No' 
			WHEN  adv.TBTreatStatCode =  'ADVREA0001'  THEN 'Yes' 
			ELSE NULL END															AS Adversereactiontomedication,
tse.Sideeffects																		AS Sideeffects,
SortId = ROW_NUMBER() OVER (PARTITION BY lp.PatID ORDER BY [ICBCode])

into #t

  FROM [$(NTBS)].[LTBI].[LTBIPatient] lp
  INNER JOIN [$(NTBS)].[LTBIReferenceData].LookICB ICB on ICB.ICBId = lp.PatICB
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].LookSICB SICB on SICB.SICBId = lp.PatSICB
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].LookSex s on s.SexId = lp.PatSex
  INNER JOIN [$(NTBS)].[LTBI].[Address] a on a.AddrId = lp.PatLastKnownAddrId
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].LookGP gp on gp.GPId = lp.PatGP
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].LookCountry cob on cob.CntryId = lp.PatCOB
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].LookEthnicity eth on eth.EthId = lp.PatEth
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].LookCountry cotr on cotr.CntryId = lp.PatCOB
  LEFT JOIN [$(NTBS)].[LTBI].TBDiseaseHistory histact on histact.TBHistPatID = lp.PatID and histact.TBHistCode = 'LTBIDIAG01'
  LEFT JOIN [$(NTBS)].[LTBI].TBDiseaseHistory histlat on histlat.TBHistPatID = lp.PatID and histlat.TBHistCode = 'LTBIDIAG575'
  LEFT JOIN [$(NTBS)].[LTBI].IGRATestInvite ti1 on ti1.IGRATestInvitePatID = lp.PatID and ti1.IGRATestInviteNumber = 1
  LEFT JOIN [$(NTBS)].[LTBI].IGRATestInvite ti2 on ti2.IGRATestInvitePatID = lp.PatID and ti2.IGRATestInviteNumber = 2
  LEFT JOIN [$(NTBS)].[LTBI].IGRATestInvite ti3 on ti3.IGRATestInvitePatID = lp.PatID and ti3.IGRATestInviteNumber = 3
  LEFT JOIN (SELECT [IGRATestPatID]
			  ,[IsIGRAReTest]
			  ,[IsIGRATestAccept]
			  ,[IGRADate]
			  ,[IGRATestNotAcceptRsnId] FROM (
		SELECT   [IGRATestPatID]
			  ,[IsIGRAReTest]
			  ,[IsIGRATestAccept]
			  ,[IGRADate]
			  ,[IGRATestNotAcceptRsnId], sortId = ROW_NUMBER() OVER (PARTITION BY [IGRATestPatID] ORDER BY [IsIGRATestAccept] DESC,[IsIGRAReTest] )
		  FROM [$(NTBS)].[LTBI].[IGRATest]) a WHERE sortId = 1) it on it.IGRATestPatID = lp.PatID
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].CodeLook clTSTNOAC on clTSTNOAC.TranLTBI = it.IGRATestNotAcceptRsnId AND clTSTNOAC.TranCategory = 'TSTNOAC'
  LEFT JOIN (SELECT IGRATestResultID,IGRATestResultPatID, IGRATestResultCode,IGRATestResultDate,DisplayMapping FROM (
					SELECT IGRATestResultID,IGRATestResultPatID, IGRATestResultCode,IGRATestResultDate,DisplayMapping, 
					SortId = ROW_NUMBER() OVER (PARTITION BY tr.IGRATestResultPatID ORDER BY c.TranNHSCode)
					FROM [$(NTBS)].[LTBI].[IGRATestResult] tr 
					INNER JOIN [$(NTBS)].[LTBIReferenceData].CodeLook c on c.TranLTBI = tr.IGRATestResultCode) a WHERE SortId = 1) 
					itr on itr.IGRATestResultPatID = lp.PatID
  LEFT JOIN [$(NTBS)].[LTBI].[IGRAReferral] ir on ir.IGRATestResultId =itr.IGRATestResultID
  LEFT JOIN [$(NTBS)].[LTBIReferenceData].CodeLook clNoReferRsn on clNoReferRsn.TranLTBI = ir.IGRATreatNoReferRsnCode AND clNoReferRsn.TranCategory = 'NOTREF' 
  LEFT JOIN (SELECT tsXRAY.TBTreatPatID,tsXRAY.[TBTreatStatDate],tsXRAY.[TBTreatStatNote], clXRAY.DisplayMapping 
					FROM [$(NTBS)].[LTBI].[TBTreatmentStatus] tsXRAY  
					INNER JOIN [$(NTBS)].[LTBIReferenceData].CodeLook clXRAY on 
					clXRAY.TranLTBI = tsXRAY.TBTreatStatCode AND clXRAY.TranCategory = 'XRAY' ) tsXRAY on tsXRAY.TBTreatPatID = lp.PatID
 LEFT JOIN (SELECT [TBTreatPatID],[TBTreatStatCode],[TBTreatStatDate],[TBTreatStatNote],
CASE	WHEN TranText = 'TB treatment accepted' THEN 'Accepted'
		WHEN TranText = 'TB treatment not accepted' THEN 'Not Accepted' 
		WHEN TranText = 'TB treatment deferred' THEN 'Deferred' END as Patienttreatmentdecision FROM (
				SELECT [TBTreatPatID],[TBTreatStatCode],[TBTreatStatDate],[TBTreatStatNote], cl.TranText, 
				SortId = ROW_NUMBER() OVER (PARTITION BY ts.[TBTreatPatID] ORDER BY cl.TranText)
				FROM [$(NTBS)].[LTBI].[TBTreatmentStatus] ts 
				INNER JOIN [$(NTBS)].[LTBIReferenceData].CodeLook cl on cl.TranLTBI = ts.TBTreatStatCode
				where TBTreatStatCode in ('IGRATREAT1','IGRATREAT11','IGRATREAT6') 
			   ) a WHERE SortId = 1) cldecision ON cldecision.TBTreatPatID = lp.PatID
 LEFT JOIN (SELECT ts.TBTreatPatID,STRING_AGG(cl.DisplayMapping, ';') 
        WITHIN GROUP (ORDER BY cl.DisplayMapping) AS Treatmentnotacceptedreason
			FROM [$(NTBS)].[LTBI].[TBTreatmentStatus] ts
			INNER JOIN [$(NTBS)].[LTBIReferenceData].CodeLook cl ON cl.TranLTBI = ts.TBTreatStatCode
			WHERE cl.TranCategory = 'TRNOAC'
			GROUP BY ts.TBTreatPatID) tnd on tnd.TBTreatPatID = lp.PatID
 LEFT JOIN (select TBTreatPatID, cl.DisplayMapping, ts.TBTreatStatNote from [$(NTBS)].[LTBI].[TBTreatmentStatus] ts
			INNER JOIN [$(NTBS)].[LTBIReferenceData].CodeLook cl on cl.TranLTBI = ts.TBTreatStatCode
			where  TranCategory = 'TRDEF') td on td.TBTreatPatID = lp.PatID
  LEFT JOIN [$(NTBS)].[LTBI].[TBTreatmentStatus] tsts on tsts.TBTreatPatID = lp.PatID and tsts.TBTreatStatCode in ('IGRATREAT5','NOTSTARTTREAT1')
  LEFT JOIN (SELECT TBTreatPatID, cl.DisplayMapping, ts.TBTreatStatNote,ts.TBTreatStatDate from [$(NTBS)].[LTBI].[TBTreatmentStatus] ts
			INNER JOIN [$(NTBS)].[LTBIReferenceData].CodeLook cl on cl.TranLTBI = ts.TBTreatStatCode AND cl.TranCategory = 'IGTR') trp on trp.TBTreatPatID = lp.PatID
 LEFT JOIN [$(NTBS)].[LTBI].[TBTreatmentStatus] tro on tro.TBTreatPatID = lp.PatID and tro.TBTreatStatCode  IN ('IGRATREAT3', 'IGRATREAT4', 'IGRATREAT7')
  LEFT JOIN (SELECT TBTreatPatID, cl.DisplayMapping, ts.TBTreatStatNote,ts.TBTreatStatDate from [$(NTBS)].[LTBI].[TBTreatmentStatus] ts
			INNER JOIN [$(NTBS)].[LTBIReferenceData].CodeLook cl on cl.TranLTBI = ts.TBTreatStatCode AND cl.TranCategory = 'TRST') trst on trst.TBTreatPatID = lp.PatID
LEFT JOIN [$(NTBS)].[LTBI].[TBTreatmentStatus] adv on adv.TBTreatPatID = lp.PatID and adv.TBTreatStatCode in ('ADVREA0001','ADVREA0009')
LEFT JOIN (SELECT tse.[TBTreatSeffPatID],STRING_AGG(cl.TranText, ';') 
        WITHIN GROUP (ORDER BY cl.DisplayMapping) AS Sideeffects
			FROM [$(NTBS)].[LTBI].[TBTreatmentSideEffect] tse
			INNER JOIN [$(NTBS)].[LTBIReferenceData].CodeLook cl ON cl.TranLTBI = tse.TBTreatSeffCode
			WHERE cl.TranCategory = 'SIDE'
			GROUP BY tse.[TBTreatSeffPatID]) tse on tse.TBTreatSeffPatID = lp.PatID;


TRUNCATE TABLE [LTBI].[LTBIBulkUploadTestingandTreatment];

INSERT INTO [LTBI].[LTBIBulkUploadTestingandTreatment]
(
[PatID]
      ,[ICBCode]
      ,[ICBName]
      ,[SICBCode]
      ,[SICBName]
      ,[NHSNumber]
      ,[GivenName]
      ,[FamilyName]
      ,[DateOfBirth]
      ,[Gender]
      ,[PatientPostcode]
      ,[GPCode]
      ,[GPPracticeName]
      ,[CountryOfBirth]
      ,[Ethnicity]
      ,[UKEntryDay]
      ,[UKEntryMonth]
      ,[UKEntryYear]
      ,[UKEntryDate]
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
      ,[Sideeffects])

	  SELECT 
	  [PatID]
      ,[ICBCode]
      ,[ICBName]
      ,[SICBCode]
      ,[SICBName]
      ,[NHSNumber]
      ,[GivenName]
      ,[FamilyName]
      ,[DateOfBirth]
      ,[Gender]
      ,[PatientPostcode]
      ,[GPCode]
      ,[GPPracticeName]
      ,[CountryOfBirth]
      ,[Ethnicity]
      ,[UKEntryDay]
      ,[UKEntryMonth]
      ,[UKEntryYear]
      ,[UKEntryDate]
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
      FROM #t WHERE SortId = 1;

END TRY
BEGIN CATCH
	THROW
END CATCH