/*This generates just the columns of data that the NOIDS extract needs. Date filtering will be done in Power BI.

The NOIDS extract requires a specificity code based on particular combinations of sites of disease*/

CREATE VIEW [dbo].[vwNOIDSExtract]
	AS

    --first create a lookup table of site name to group mappings
	WITH NOIDSSiteGroupings AS
    (
       SELECT 'Pulmonary' AS SiteDescription, 'PulmonaryMiliary' AS SiteGroup
       UNION
       SELECT 'Miliary' AS SiteDescription, 'PulmonaryMiliary' AS SiteGroup
       UNION
       SELECT 'Meningitis' AS SiteDescription, 'Meningitis' AS SiteGroup
       UNION
       SELECT 'Lymph nodes: Intra-thoracic' AS SiteDescription, 'LymphNodes' AS SiteGroup
       UNION
	   SELECT 'Intra-thoracic' AS SiteDescription, 'LymphNodes' AS SiteGroup
       UNION
       SELECT 'Pleural' AS SiteDescription, 'Pleural' AS SiteGroup
       UNION
       SELECT 'Other' AS SiteDescription, 'Other' AS SiteGroup
    
    ),

    --get all sites of disease from both NTBS and ETS, and standardise on the NTBS names
    NotificationSites AS

    (
        SELECT n.LegacyId AS NotificationId, sites.NtbsLabel AS SiteName
        FROM RecordRegister rr
            INNER JOIN [$(OtherServer)].[$(ETS)].dbo.[Notification] n ON rr.NotificationId = n.LegacyId
            LEFT OUTER JOIN [$(OtherServer)].[$(ETS)].dbo.TuberculosisEpisodeDiseaseSite diseaseSite ON n.TuberculosisEpisodeId = diseaseSite.TuberculosisEpisodeId
            LEFT OUTER JOIN [$(migration)].dbo.DiseaseSiteMapping sites ON sites.EtsID = diseaseSite.DiseaseSiteId
            INNER JOIN [dbo].vwNotificationYear ny ON ny.NotificationYear = YEAR(rr.NotificationDate)
        WHERE rr.SourceSystem = 'ETS' AND diseaseSite.AuditDelete IS NULL AND ny.Id > -2 AND rr.Denotified = 0
        UNION
        SELECT rr.NotificationId, [Description]
        FROM RecordRegister rr
            INNER JOIN [$(NTBS)].[dbo].[NotificationSite] notificationSite ON rr.NotificationId = notificationSite.NotificationId
            INNER JOIN [$(NTBS)].[ReferenceData].[Site] sites ON notificationSite.SiteId = sites.SiteId
            INNER JOIN [dbo].vwNotificationYear ny ON ny.NotificationYear = YEAR(rr.NotificationDate)
        WHERE rr.SourceSystem = 'NTBS' AND ny.Id > -2  AND rr.Denotified = 0
       ),
    
    --then apply the appropriate group name to each notification site of disease
    --this needs to allow for the few notifications in ETS which have no sites of disease at all. Ultimately the 
    --specificity_code for these records should come out as null, not 4 (other)
    GroupedSites AS
    (
        SELECT DISTINCT 
            ns.NotificationId, 
            CASE 
                WHEN g.SiteDescription IS NOT NULL THEN g.SiteGroup
			    WHEN ns.SiteName IS NOT NULL THEN 'Other'
			    ELSE NULL
			END AS SiteGroup FROM NotificationSites ns
                LEFT OUTER JOIN NOIDSSiteGroupings g ON g.SiteDescription = ns.SiteName
    ),

    --now generate a list with one row for every notification ID and site group combination
    AllCombos AS
    (
        SELECT DISTINCT NotificationId, SiteGroup  
        FROM NotificationSites, NOIDSSiteGroupings  
    ),


    
    --and now add a 1 for each site group which the notification has, otherwise a 0
    NotificationAllSites AS
    (
        SELECT ac.NotificationId, ac.SiteGroup, CASE WHEN gs.NotificationId IS NULL THEN 0 ELSE 1 END AS HasSite 
        FROM AllCombos ac
            LEFT OUTER JOIN GroupedSites gs ON gs.NotificationId = ac.NotificationId AND gs.SiteGroup = ac.SiteGroup),

    --pivot these rows so one row per notification
    PivotedSites AS
    (
        SELECT * 
        FROM NotificationAllSites  AS source
             PIVOT
             (
                MAX(HasSite)
                FOR [SiteGroup] IN ([PulmonaryMiliary], [Meningitis], [Other], [LymphNodes], [Pleural])
             ) 
             AS Result
     ),

    -- and now finally generate the appropriate specificity code based on the combination of site groups
    SpecificityCode AS
    (SELECT NotificationId,
        CASE
           WHEN PulmonaryMiliary = 1 AND Meningitis = 1 THEN 5
           WHEN PulmonaryMiliary = 1 AND Other = 1 THEN 6
           WHEN PulmonaryMiliary = 1 THEN 1

           
           --7 must have lymphnodes and must have cnsmeningitis and mustn't have pleural
           WHEN PulmonaryMiliary = 0 AND LymphNodes = 1 AND Meningitis = 1 AND Pleural = 0  THEN 7
           --8 must have lymph nodes, mustn't have pleural and must have other
           WHEN PulmonaryMiliary = 0 AND LymphNodes = 1 and Pleural = 0 and Other = 1 THEN 8
           WHEN PulmonaryMiliary = 0 AND (LymphNodes = 1 OR Pleural = 1) THEN 2
           WHEN Meningitis = 1 THEN 3
           WHEN Other = 1 THEN 4
           --error code which will be reported out in Power BI
           ELSE ''
          END
        AS Specificity_Code
    FROM PivotedSites)


    --then construct all the required fields.  The Notification date will appear twice, once as a formatted string to ensure
    --the download 
    SELECT 
        cd.Hospital AS hospital, 
        COALESCE(p.HPA_CD, etsh.LocalAuthorityCode) AS Local_Authority,
        FORMAT(cd.SymptomOnsetDate, 'dd/MM/yyyy') AS Date_Symptomonset, 
        FORMAT(COALESCE(cd.FirstPresentationDate, cd.TbServicePresentationDate) , 'dd/MM/yyyy') AS Date_Consultation,
        FORMAT(rr.NotificationDate, 'dd/MM/yyyy') AS Date_Notified,
        --supply the ETS ID if there is one, as this is the ID NOIDS will previously have received for the case
        COALESCE(cd.EtsId, rr.NotificationId) AS Unique_ID,
        23 AS Disease_Code, 
        s.Specificity_Code, 
        cd.Age, 
        CASE cd.Sex 
            WHEN 'Male' THEN 1 
            WHEN 'Female' THEN 2 
            ELSE 3 END 
        AS Sex,
        CASE 
            WHEN cd.EthnicGroup = 'White' AND cd.BirthCountry = 'UNITED KINGDOM' THEN 'A'
            WHEN cd.EthnicGroup = 'White' AND cd.BirthCountry = 'IRELAND' THEN 'B'
            WHEN cd.EthnicGroup = 'White' THEN 'C'
            WHEN cd.EthnicGroup = 'Indian' THEN 'H'
            WHEN cd.EthnicGroup = 'Pakistani' THEN 'J'
            WHEN cd.EthnicGroup = 'Bangladeshi' THEN 'K'
            WHEN cd.EthnicGroup LIKE '%Caribbean%' THEN 'M'
            WHEN cd.EthnicGroup LIKE '%African%' THEN 'N'
            WHEN cd.EthnicGroup LIKE '%Black%' THEN 'P'
            WHEN cd.EthnicGroup = 'Chinese' THEN 'R'
            WHEN cd.EthnicGroup LIKE '%Mixed%' THEN 'S'
            ELSE 'Z' 
        END AS Ethnicity,
        pd.Postcode,
        rr.NotificationDate,
        rr.SourceSystem
        FROM [dbo].RecordRegister rr
            INNER JOIN [dbo].Record_CaseData cd ON cd.NotificationId = rr.NotificationId
            INNER JOIN [dbo].Record_PersonalDetails pd ON pd.NotificationId = rr.NotificationId
            INNER JOIN SpecificityCode s ON s.NotificationId = rr.NotificationId
            LEFT JOIN [$(NTBS_R1_Geography_Staging)].dbo.Reduced_Postcode_file p on p.Pcode = Replace(pd.Postcode,' ','')
            LEFT JOIN [$(migration)].dbo.ETS_Hospital etsh ON etsh.Id = cd.HospitalId
       --coalesce residence phec code to ensure NULL entries (i.e. no fixed abode) are not dropped
       WHERE rr.Denotified = 0 AND COALESCE(rr.ResidencePhecCode, 'NULL VALUE') NOT IN ('PHECSCOT', 'PHECNI')

