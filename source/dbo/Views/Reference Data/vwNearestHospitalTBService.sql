CREATE VIEW [dbo].[vwNearestHospitalTBService]
	AS 

	SELECT
	Postcode,
	h.HospitalName,
	TB_Service_Name
	FROM [$(NTBS_R1_Geography_Staging)].[dbo].[Reduced_Postcode_file] p
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[Hospital] h ON
	h.HospitalId = p.Closest_Hospital_ID 
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service_to_Hospital] t ON
	t.HospitalID = p.Closest_Hospital_ID
	INNER JOIN [$(NTBS_R1_Geography_Staging)].[dbo].[TB_Service] tb ON
	tb.TB_Service_Code = t.TB_Service_Code


