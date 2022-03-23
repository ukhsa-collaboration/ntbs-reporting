CREATE VIEW [dbo].[vwHospital]
	AS
	SELECT h.[HospitalId]
      ,h.[HospitalName]
      ,CASE WHEN [IsLegacy] = 1 THEN 'No' ELSE 'Yes' END AS [StillInUse]
	  ,tbh.TB_Service_Code
	FROM [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] tbh ON tbh.HospitalID = h.HospitalId
