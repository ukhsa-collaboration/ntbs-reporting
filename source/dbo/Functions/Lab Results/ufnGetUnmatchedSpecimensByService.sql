
CREATE FUNCTION [dbo].[ufnGetUnmatchedSpecimensByService] 
(	
	--comma-separated list to be split using select value from STRING_SPLIT(@Service, ',')
	@Service VARCHAR(1000)		=	NULL
	
)
RETURNS TABLE 
AS
RETURN 
(
	
	SELECT 
	nsm.ReferenceLaboratoryNumber, 
	ls.SpecimenDate, 
	ls.SpecimenTypeCode, 
	ls.LaboratoryName, 
	ls.ReferenceLaboratory, 
	ls.Species, 
	ls.PatientNhsNumber AS 'LabPatientNHSNumber', 
	ls.PatientBirthDate AS 'LabPatientBirthDate', 
	ls.PatientName AS 'LabPatientName', 
	ls.PatientSex AS 'LabPatientSex', 
	ls.PatientAddress AS 'LabPatientAddress', 
	ls.PatientPostcode AS 'LabPatientPostcode',  
	nsm.NotificationID, 
	n.NotificationDate,
	--TODO: CONCAT THIS WITH NOT KNOWN FIELD
	p.NhsNumber as 'NTBSPatientNHSNumber', 
	
	CONCAT(UPPER(p.FamilyName), ', ', p.GivenName) AS 'NTBSPatientName',
	p.Dob as 'NTBSPatientBirthDate',
	p.[Address] as 'NTBSPatientAddress',
	p.Postcode as 'NTBSPatientPostcode',
	s.Label,
	tbs.TB_Service_Name,
	ConfidenceLevel 
FROM [$(NTBS_Specimen_Matching)].[dbo].NotificationSpecimenMatch nsm
	INNER JOIN [dbo].[LabSpecimen] ls ON ls.ReferenceLaboratoryNumber = nsm.ReferenceLaboratoryNumber
	INNER JOIN [$(NTBS)].[dbo].[Notification] n ON n.NotificationId = nsm.NotificationID
	INNER JOIN [$(NTBS)].[dbo].[Episode] e ON e.NotificationId = nsm.NotificationID
	INNER JOIN [$(NTBS)].[dbo].[Patients] p ON p.NotificationId = n.NotificationId
	LEFT OUTER JOIN [dbo].[TB_Service] tbs ON e.TBServiceCode = tbs.TB_Service_Code
	LEFT OUTER JOIN [$(NTBS)].[dbo].[Sex] s ON s.SexId = p.SexId
 where MatchType = 'Possible'
)