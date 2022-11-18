CREATE VIEW [dbo].[vwNearestHospitalTBService]
	AS 

	SELECT
	p.Pcode as 'Postcode',
	h1.HospitalName as 'Nearest_Hospital',
	h2.HospitalName as 'Second_Nearest_Hospital',
	h3.HospitalName as 'Third_Nearest_Hospital',
	TB1.TB_Service_Name as 'Nearest_TBService',
	TB2.TB_Service_Name as 'Second_Nearest_TBService',
	TB3.TB_Service_Name as 'Third_Nearest_TBService'
	FROM [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] p
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h1 ON
	h1.HospitalId = p.Closest_Hospital_ID 
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] t1 ON
	t1.HospitalID = h1.HospitalId
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tb1 ON
	tb1.TB_Service_Code = t1.TB_Service_Code
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h2 ON
	h2.HospitalId = p.Second_Closest_Hospital 
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] t2 ON
	t2.HospitalID = h2.HospitalId
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tb2 ON
	tb2.TB_Service_Code = t2.TB_Service_Code
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h3 ON
	h3.HospitalId = p.Third_Closest_Hospital 
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] t3 ON
	t3.HospitalID = h3.HospitalId
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tb3 ON
	tb3.TB_Service_Code = t3.TB_Service_Code

