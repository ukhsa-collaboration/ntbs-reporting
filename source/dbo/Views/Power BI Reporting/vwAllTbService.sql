CREATE VIEW [dbo].[vwAllTbService]
	AS
	SELECT 
		tbp.PHEC_Code, 
		tbs.TB_Service_Code, 
		tbs.TB_Service_Name, 
		tbs.IsLegacy AS IsServiceLegacy
	 FROM [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tbs
		INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.TB_Service_Code = tbs.TB_Service_Code
		INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_PHEC] tbp ON tbp.TB_Service_Code = tbs.TB_Service_Code
