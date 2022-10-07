CREATE VIEW [dbo].[vwNearestHospitalTBService]
	AS 

	SELECT
	p.Pcode as 'Postcode',
	h.HospitalName as 'Nearest_Hospital',
	TB_Service_Name as 'Nearest_TBService'
	FROM [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] p
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h ON
	h.HospitalId = p.Closest_Hospital_ID 
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] t ON
	t.HospitalID = h.HospitalId
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tb ON
	tb.TB_Service_Code = t.TB_Service_Code


