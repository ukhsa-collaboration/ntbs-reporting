/*This view replaces the legacy lab result extract in ETS. It includes both manually-entered results
and reference lab results.  It already has a column called 'Source' which displays 'ETS' for manually-entered results
and 'MycobNet' for reference lab results, so these values have been preserved, even when the source is actually
NTBS*/


CREATE VIEW [dbo].[vwLegacyLabExtract]
	AS
	--start off with the list of all matched specimens for the cases in the scope of the reporting service

    WITH MatchedSpecimens AS
    (
        SELECT rr.NotificationId, rr.SourceSystem, nsm.ReferenceLaboratoryNumber, 
            CASE 
                WHEN nsm.MatchMethod IN ('Automatch', 'Migration') THEN 'Auto'
                ELSE 'Manual'
		    END							AS MatchType
        FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch] nsm
	        INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = nsm.NotificationID
        WHERE nsm.MatchType = 'Confirmed' AND rr.SourceSystem = 'NTBS'
    
        UNION
        SELECT rr.NotificationId, rr.SourceSystem, esm.ReferenceLaboratoryNumber, 
            CASE esm.Automatched 
                WHEN 1 THEN 'Auto' 
                ELSE 'Manual' 
            END AS MatchType
        FROM [$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch] esm
            INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = esm.LegacyId
        WHERE rr.SourceSystem = 'ETS'
    ),

    --we need to get some values from anonymised, and we want to make sure we only get the most recent anonymised record that relates to the ref lab number
    PatientIdAndSourceLab AS
    (
        SELECT 
            m.ReferenceLaboratoryNumber,
            MAX(a.HospitalPatientNumber)		AS 'PatientId', 
            MAX(a.SourceLaboratoryNumber)		AS 'SourceLaboratoryNumber'
	    FROM [$(Labbase2)].[dbo].[Anonymised] a
	        INNER JOIN MatchedSpecimens m ON m.ReferenceLaboratoryNumber = a.ReferenceLaboratoryNumber
        GROUP BY m.ReferenceLaboratoryNumber
    ),

    --and then build the suscepctibility results before stitching all the data together
    --we want one row for each ref lab number and antibiotic, regardless of whether or not there is a result for it

    AllSusceptibilityCombinations AS
    (
        SELECT m.ReferenceLaboratoryNumber, al.AntibioticOutputName
		FROM  MatchedSpecimens m, [$(NTBS_Specimen_Matching)].[dbo].[AntibioticLookup] al

    ),

      --take the highest ranked result for each ref lab number and antibiotic combination
    AvailableResults AS
    (
        SELECT DISTINCT 
            lsr.ReferenceLaboratoryNumber, 
            lsr.AntibioticOutputName, 
            FIRST_VALUE(LEFT(lsr.ResultOutputName, 1)) OVER (PARTITION BY lsr.ReferenceLaboratorynumber, lsr.AntibioticOutputName ORDER BY [Rank]) AS Result
        FROM [$(NTBS_Specimen_Matching)].[dbo].[StandardisedLabbaseSusceptibilityResult] lsr
	        INNER JOIN MatchedSpecimens ms ON ms.ReferenceLaboratoryNumber = lsr.ReferenceLaboratoryNumber
        WHERE lsr.ResultOutputName IN ('Sensitive', 'Resistant')
    ),

    AllResults AS
    (
        SELECT 
            a.ReferenceLaboratoryNumber, 
            a.AntibioticOutputName, 
            ar.Result
		FROM AllSusceptibilityCombinations a
			LEFT OUTER JOIN AvailableResults ar ON ar.AntibioticOutputName = a.AntibioticOutputName AND ar.ReferenceLaboratoryNumber = a.ReferenceLaboratoryNumber
    ),

    --and then pivot them, so we only return one row for the given RefLabNumber
	SusceptiblityResults AS
	(
        SELECT * FROM AllResults
		AS source
		PIVOT
			(
				MAX(Result)
				FOR [AntibioticOutputName] IN ([INH], [RIF], [EMB], [PZA], [STR], [AK], [AZI], [CAP], [CIP], [CLA], [CLO], [CYC], [ETI], [PAS], [PRO], [RB], [MFX], [OFX], [KAN], [LZD])
		    ) AS Result
    )
		
--and now stitch it all together


	SELECT 
	    mtr.[NotificationId]			    AS 'NotificationId'
        ,cd.EtsId						    AS 'EtsId'
        ,'NTBS'							    AS 'SourceSystem'
        ,cd.LtbrId						    AS 'IdOriginal'
        ,'ETS'							    AS 'Source'
        ,CASE 
		    WHEN tt.[Description] = 'Smear' THEN 'Microscopy'
		    WHEN tt.[Description] = 'Culture' THEN 'Mycobacterial Culture'
		    WHEN tt.[Description] IN ('Line probe assay','PCR') THEN 'Molecular Amplification'
		    ELSE tt.[Description]
	    END								    AS 'LaboratoryTestType'
        ,st.[Description]				    AS 'Specimen'
        ,mtr.[TestDate]					    AS 'SpecimenDate'
        ,mtr.[Result]
        ,NULL								AS 'Species'
        ,NULL								AS 'SourceLabName'
        ,NULL								AS 'PatientId' 
        ,NULL								AS 'OpieId'
        ,NULL								AS 'Isoniazid'
        ,NULL								AS 'Rifampicin'
        ,NULL								AS 'Ethambutol'
        ,NULL								AS 'Pyrazinamide'
        ,NULL								AS 'Streptomycin'
        ,NULL								AS 'Amikacin'
        ,NULL								AS 'Azithromycin'
        ,NULL								AS 'Capreomycin'
        ,NULL								AS 'Ciprofloxacin'
        ,NULL								AS 'Clarithromycin'
        ,NULL								AS 'Clofazimine'
        ,NULL								AS 'Cycloserine'
        ,NULL								AS 'Ethionamide'
        ,NULL								AS 'PAS'
        ,NULL								AS 'Prothionamide'
        ,NULL								AS 'Rifabutin'
        ,NULL								AS 'Moxifloxacin'
        ,NULL								AS 'Ofloxacin'
        ,NULL								AS 'Kanamycin'
        ,NULL								AS 'Linezolid'
        ,NULL								AS 'ReferenceLaboratory'
        ,NULL								AS 'ReferenceLaboratoryNumber'
        ,NULL								AS 'SourceLaboratoryNumber'
        ,NULL								AS 'StrainType'
        ,NULL								AS 'Comments'
        ,NULL								AS 'MatchType'
    FROM [$(NTBS)].[dbo].[ManualTestResult] mtr
        INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = mtr.NotificationId AND rr.SourceSystem = 'NTBS'
        INNER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = rr.NotificationId
        LEFT OUTER JOIN [$(NTBS)].[ReferenceData].ManualTestType tt ON tt.ManualTestTypeId = mtr.ManualTestTypeId
        LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[SampleType] st ON st.SampleTypeId = mtr.SampleTypeId
    WHERE mtr.ManualTestTypeId != 4 --exclude chest x-ray results

    UNION
    
    SELECT DISTINCT
		m.NotificationID				AS 'NotificationId'
        ,CASE 
			WHEN m.SourceSystem = 'NTBS' THEN cd.EtsId 
			ELSE m.NotificationId 
		 END 							AS 'Id'
        ,m.SourceSystem					AS 'SourceSystem'
        ,cd.LtbrId					AS 'IdOriginal'
        ,'MycobNet'						AS 'Source'
        ,'Mycobacterial Culture'		AS 'LaboratoryTestType'
        ,ls.SpecimenTypeCode			AS 'Specimen'
        ,ls.SpecimenDate				AS 'SpecimenDate'
        ,'Positive'						AS 'Result'
        ,REPLACE(ls.Species, 'M.', 'Mycobacterium') AS 'Species'
        ,ls.LaboratoryName				AS 'SourceLabName'
        ,ps.PatientId					AS 'PatientId' 
        ,NULL							AS 'OpieId'
        ,si.INH							AS 'Isoniazid'
        ,si.RIF							AS 'Rifampicin'
        ,si.EMB							AS 'Ethambutol'
        ,si.PZA							AS 'Pyrazinamide'
        ,si.[STR]						AS 'Streptomycin'
        ,si.AK							AS 'Amikacin'
        ,si.AZI							AS 'Azithromycin'
        ,si.CAP							AS 'Capreomycin'
        ,si.CIP							AS 'Ciprofloxacin'
        ,si.CLA							AS 'Clarithromycin'
        ,si.CLO							AS 'Clofazimine'
        ,si.CYC							AS 'Cycloserine'
        ,si.ETI							AS 'Ethionamide'
        ,si.PAS							AS 'PAS'
        ,si.PRO							AS 'Prothionamide'
        ,si.RB							AS 'Rifabutin'
        ,si.MFX							AS 'Moxifloxacin'
        ,si.OFX							AS 'Ofloxacin'
        ,si.KAN							AS 'Kanamycin'
        ,si.LZD							AS 'Linezolid'
        ,ls.ReferenceLaboratory			AS 'ReferenceLaboratory'
        ,m.ReferenceLaboratoryNumber	AS 'ReferenceLaboratoryNumber'
        ,ps.SourceLaboratoryNumber		AS 'SourceLaboratoryNumber'
        ,''								AS 'StrainType'
        ,NULL							AS 'Comments'
        ,m.MatchType
	FROM MatchedSpecimens m  
	    LEFT OUTER JOIN [dbo].[Record_CaseData] cd ON cd.NotificationId = m.NotificationId
	    LEFT OUTER JOIN [$(NTBS_Specimen_Matching)].[dbo].[LabSpecimen] ls ON ls.ReferenceLaboratoryNumber = m.ReferenceLaboratoryNumber
	    LEFT OUTER JOIN PatientIdAndSourceLab ps ON ps.ReferenceLaboratoryNumber = m.ReferenceLaboratoryNumber
	    LEFT OUTER JOIN SusceptiblityResults si ON si.ReferenceLaboratoryNumber = m.ReferenceLaboratoryNumber

	UNION

	SELECT 
		rr.NotificationId			
        ,rr.NotificationId			AS 'EtsId'
        ,rr.SourceSystem			
        ,dl.IDOriginal
        ,'ETS'							AS 'Source'
		,dl.LaboratoryTestType
		,dl.Specimen
		,dl.SpecimenDate
		,dl.Result
		,dl.Species
		,dl.SourceLabName
        ,dl.PatientId
		,dl.OpieID
		,dl.Isoniazid
		,dl.Rifampicin
		,dl.Ethambutol
		,dl.Pyrazinamide
		,dl.Streptomycin
		,dl.Amikacin
		,dl.Azithromycin
		,dl.Capreomycin
		,dl.Ciprofloxacin
		,dl.Clarithromycin
		,dl.Clofazimine
		,dl.Cycloserine
		,dl.Ethionamide
		,dl.PAS
		,dl.Prothionamide
		,dl.Rifabutin
		,dl.Moxifloxacin
		,dl.Ofloxacin
		,dl.Kanamycin
		,dl.Linezolid
		,dl.ReferenceLaboratory
		,dl.ReferenceLaboratoryNumber
		,dl.SourceLaboratoryNumber
		,dl.StrainType
		,NULL AS Comments
		,dl.MatchType
    FROM [dbo].[RecordRegister] rr
		INNER JOIN [$(ETS)].[dbo].[DataExportLaboratoryTable] dl ON dl.ID = rr.NotificationId
	WHERE rr.SourceSystem = 'ETS' AND dl.[Source] = 'ETS'
