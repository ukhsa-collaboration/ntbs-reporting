/*this completes the set of fact tables for Power BI Reporting. The data is mastered in the specimen matching database and this
view will ensure we can pull through the entries we want into Power BI from the reporting database*/


CREATE VIEW [dbo].[Record_CultureAndResistance]
	AS 
	SELECT 
        ncr.[NotificationId]
        ,ncr.[SourceSystem]
        ,[CulturePositive]
        ,[Species]
        ,[EarliestSpecimenDate]
        ,[DrugResistanceProfile]
        ,[INH]
        ,[RIF]
        ,[EMB]
        ,[PZA]
        ,[AMINO]
        ,[QUIN]
        ,[MDR]
        ,[XDR]
  FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationCultureResistanceSummary] ncr
    INNER JOIN [dbo].[RecordRegister] rr ON rr.NotificationId = ncr.NotificationId
