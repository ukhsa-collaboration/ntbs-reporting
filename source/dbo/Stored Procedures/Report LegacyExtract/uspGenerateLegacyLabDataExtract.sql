CREATE PROCEDURE [dbo].[uspGenerateLegacyLabDataExtract]
	
AS

BEGIN TRY
	--reset
	TRUNCATE TABLE [dbo].[LegacyLabExtract]

	--populate for NTBS manual
    DECLARE @IncludeNTBS BIT = (SELECT TOP(1) IncludeNTBS FROM [dbo].[ReportingFeatureFlags])
	IF @IncludeNTBS = 1
	BEGIN

	    INSERT INTO [dbo].[LegacyLabExtract]
               ([NotificationId]
		       ,[NtbsId]
               ,[EtsId]
               ,[SourceSystem]
               ,[IDOriginal]
               ,[Source]
               ,[LaboratoryTestType]
               ,[Specimen]
               ,[SpecimenDate]
               ,[Result]
               ,[Species]
               ,[SourceLabName]
               ,[PatientId]
               ,[OpieID]
               ,[Isoniazid]
               ,[Rifampicin]
               ,[Ethambutol]
               ,[Pyrazinamide]
               ,[Streptomycin]
               ,[Amikacin]
               ,[Azithromycin]
               ,[Capreomycin]
               ,[Ciprofloxacin]
               ,[Clarithromycin]
               ,[Clofazimine]
               ,[Cycloserine]
               ,[Ethionamide]
               ,[PAS]
               ,[Prothionamide]
               ,[Rifabutin]
               ,[Moxifloxacin]
               ,[Ofloxacin]
               ,[Kanamycin]
               ,[Linezolid]
               ,[ReferenceLaboratory]
               ,[ReferenceLaboratoryNumber]
               ,[SourceLaboratoryNumber]
               ,[StrainType]
               ,[Comments]
               ,[MatchType])
		    SELECT 
			    mtr.[NotificationId]			AS 'NotificationId'
                ,mtr.[NotificationId]			AS 'NTBSId'
                ,le.EtsId						AS 'EtsId'
                ,'NTBS'							AS 'SourceSystem'
                ,le.IDOriginal					AS 'IdOriginal'
                ,'ETS'							AS 'Source'
                ,CASE 
				    WHEN tt.[Description] = 'Smear' THEN 'Microscopy'
				    WHEN tt.[Description] = 'Culture' THEN 'Mycobacterial Culture'
				    WHEN tt.[Description] IN ('Line probe assay','PCR') THEN 'Molecular Amplification'
				    ELSE tt.[Description]
			    END								AS 'LaboratoryTestType'
                ,st.[Description]				AS 'Specimen'
                ,mtr.[TestDate]					AS 'SpecimenDate'
                ,mtr.[Result]
                ,''								AS 'Species'
                ,''								AS 'SourceLabName'
                ,''								AS 'PatientId' 
                ,''								AS 'OpieId'
                ,''								AS 'Isoniazid'
                ,''								AS 'Rifampicin'
                ,''								AS 'Ethambutol'
                ,''								AS 'Pyrazinamide'
                ,''								AS 'Streptomycin'
                ,''								AS 'Amikacin'
                ,''								AS 'Azithromycin'
                ,''								AS 'Capreomycin'
                ,''								AS 'Ciprofloxacin'
                ,''								AS 'Clarithromycin'
                ,''								AS 'Clofazimine'
                ,''								AS 'Cycloserine'
                ,''								AS 'Ethionamide'
                ,''								AS 'PAS'
                ,''								AS 'Prothionamide'
                ,''								AS 'Rifabutin'
                ,''								AS 'Moxifloxacin'
                ,''								AS 'Ofloxacin'
                ,''								AS 'Kanamycin'
                ,''								AS 'Linezolid'
                ,''								AS 'ReferenceLaboratory'
                ,''								AS 'ReferenceLaboratoryNumber'
                ,''								AS 'SourceLaboratoryNumber'
                ,''								AS 'StrainType'
                ,''								AS 'Comments'
                ,''								AS 'MatchType'
	      FROM [$(NTBS)].[dbo].[ManualTestResult] mtr
            INNER JOIN [dbo].[LegacyExtract] le ON le.NtbsId = mtr.NotificationId AND le.SourceSystem = 'NTBS'
            LEFT OUTER JOIN [$(NTBS)].[ReferenceData].ManualTestType tt ON tt.ManualTestTypeId = mtr.ManualTestTypeId
            LEFT OUTER JOIN [$(NTBS)].[ReferenceData].[SampleType] st ON st.SampleTypeId = mtr.SampleTypeId
	      WHERE mtr.ManualTestTypeId != 4

          --populate for NTBS reference
          INSERT INTO [dbo].[LegacyLabExtract]
               ([NotificationId]
		       ,[NtbsId]
               ,[EtsId]
               ,[SourceSystem]
               ,[IDOriginal]
               ,[Source]
               ,[LaboratoryTestType]
               ,[Specimen]
               ,[SpecimenDate]
               ,[Result]
               ,[Species]
               ,[SourceLabName]
               ,[PatientId]
               ,[OpieID]
               ,[Isoniazid]
               ,[Rifampicin]
               ,[Ethambutol]
               ,[Pyrazinamide]
               ,[Streptomycin]
               ,[Amikacin]
               ,[Azithromycin]
               ,[Capreomycin]
               ,[Ciprofloxacin]
               ,[Clarithromycin]
               ,[Clofazimine]
               ,[Cycloserine]
               ,[Ethionamide]
               ,[PAS]
               ,[Prothionamide]
               ,[Rifabutin]
               ,[Moxifloxacin]
               ,[Ofloxacin]
               ,[Kanamycin]
               ,[Linezolid]
               ,[ReferenceLaboratory]
               ,[ReferenceLaboratoryNumber]
               ,[SourceLaboratoryNumber]
               ,[StrainType]
               ,[Comments]
               ,[MatchType])
          SELECT DISTINCT
			    nsm.NotificationID				AS 'NotificationId'
                ,nsm.[NotificationID]			AS 'NTBSId'
                ,le.EtsId						AS 'Id'
                ,'NTBS'							AS 'SourceSystem'
                ,le.IDOriginal					AS 'IdOriginal'
                ,'MycobNet'						AS 'Source'
                ,'Mycobacterial Culture'		AS 'LaboratoryTestType'
                ,ls.SpecimenTypeCode			AS 'Specimen'
                ,ls.SpecimenDate				AS 'SpecimenDate'
                ,'Positive'						AS 'Result'
                ,REPLACE(ls.Species, 'M.', 'Mycobacterium') AS 'Species'
                ,ls.LaboratoryName				AS 'SourceLabName'
                ,a.HospitalPatientNumber		AS 'PatientId' 
                ,lbs.OpieId						AS 'OpieId'
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
                ,a.ReferenceLaboratory			AS 'ReferenceLaboratory'
                ,nsm.ReferenceLaboratoryNumber	AS 'ReferenceLaboratoryNumber'
                ,a.SourceLaboratoryNumber		AS 'SourceLaboratoryNumber'
                ,''								AS 'StrainType'
                ,COALESCE(a.Comments, '')		AS 'Comments'
                ,(CASE 
				    WHEN nsm.MatchMethod IN ('Automatch', 'Migration') THEN 'Auto'
				    ELSE 'Manual'
			    END)							AS 'MatchType'
	      FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch] nsm
            INNER JOIN [dbo].[LegacyExtract] le ON le.NtbsId = nsm.NotificationID AND le.SourceSystem = 'NTBS'
		    INNER JOIN [dbo].[LabSpecimen] ls ON ls.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber
		    INNER JOIN [dbo].[StandardisedLabbaseSpecimen] lbs ON lbs.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber
		    INNER JOIN [$(Labbase2)].[dbo].[Anonymised] a ON a.OpieId = lbs.OpieId
		    CROSS APPLY [dbo].[ufnGetIsolateSusceptibilityInfo](lbs.OpieId) si
	      WHERE nsm.MatchType = 'Confirmed' 

	END

    DECLARE @IncludeETS BIT = (SELECT TOP(1) IncludeETS FROM [dbo].[ReportingFeatureFlags])
	IF @IncludeETS = 1
    BEGIN
	    --and then copy over from ETS for ETS-sourced records
        INSERT INTO [dbo].[LegacyLabExtract]
               ([NotificationId]
               ,[EtsId]
               ,[SourceSystem]
               ,[IDOriginal]
               ,[Source]
               ,[LaboratoryTestType]
               ,[Specimen]
               ,[SpecimenDate]
               ,[Result]
               ,[Species]
               ,[SourceLabName]
               ,[PatientId]
               ,[OpieID]
               ,[Isoniazid]
               ,[Rifampicin]
               ,[Ethambutol]
               ,[Pyrazinamide]
               ,[Streptomycin]
               ,[Amikacin]
               ,[Azithromycin]
               ,[Capreomycin]
               ,[Ciprofloxacin]
               ,[Clarithromycin]
               ,[Clofazimine]
               ,[Cycloserine]
               ,[Ethionamide]
               ,[PAS]
               ,[Prothionamide]
               ,[Rifabutin]
               ,[Moxifloxacin]
               ,[Ofloxacin]
               ,[Kanamycin]
               ,[Linezolid]
               ,[ReferenceLaboratory]
               ,[ReferenceLaboratoryNumber]
               ,[SourceLaboratoryNumber]
               ,[StrainType]
               ,[Comments]
               ,[MatchType])
            SELECT
               [ID]				AS NotificationId
              ,[ID]
              ,'ETS'			AS 'SourceSystem'
              ,et.[IDOriginal]
              ,[Source]
              ,[LaboratoryTestType]
              ,[Specimen]
              ,[SpecimenDate]
              ,[Result]
              ,[Species]
              ,[SourceLabName]
              ,[PatientId]
              ,[OpieID]
              ,[Isoniazid]
              ,[Rifampicin]
              ,[Ethambutol]
              ,[Pyrazinamide]
              ,[Streptomycin]
              ,[Amikacin]
              ,[Azithromycin]
              ,[Capreomycin]
              ,[Ciprofloxacin]
              ,[Clarithromycin]
              ,[Clofazimine]
              ,[Cycloserine]
              ,[Ethionamide]
              ,[PAS]
              ,[Prothionamide]
              ,[Rifabutin]
              ,[Moxifloxacin]
              ,[Ofloxacin]
              ,[Kanamycin]
              ,[Linezolid]
              ,[ReferenceLaboratory]
              ,[ReferenceLaboratoryNumber]
              ,[SourceLaboratoryNumber]
              ,[StrainType]
              ,et.[Comments]
              ,[MatchType]
      FROM [$(ETS)].[dbo].[DataExportLaboratoryTable] et
        INNER JOIN [dbo].[LegacyExtract] le ON le.EtsId = et.[ID] AND le.SourceSystem = 'ETS'
    END
END TRY
BEGIN CATCH
	THROW
END CATCH

RETURN 0
