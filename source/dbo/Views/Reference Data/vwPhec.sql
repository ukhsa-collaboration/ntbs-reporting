CREATE VIEW [dbo].[vwPhec]
	AS 
	SELECT 
		[PHEC_Code]
		,[PHEC_Name]
		,[AdGroupName]
  FROM [$(NTBS_R1_Geography_Staging)].[dbo].[PHEC]