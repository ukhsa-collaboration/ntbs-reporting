/*CREATE FUNCTION [dbo].[ufnGetAllUnmatchedSpecimens] 
(	
	
)

RETURNS TABLE 
AS

RETURN 
	
SELECT 
	vpm.ReferenceLaboratoryNumber
	,vpm.SpecimenDate
	,vpm.SpecimenTypeCode
	,vpm.LaboratoryName
	,vpm.ReferenceLaboratory
	,vpm.Species
	,vpm.LabNhsNumber
	,vpm.LabBirthDate
	,vpm.LabName
	,vpm.LabSex
	,vpm.LabAddress
	,vpm.LabPostcode
	,vpm.TbServiceName
	,vpm.NotificationID
	,vpm.NotificationDate
	,vpm.NtbsNhsNumber
	,vpm.NtbsName
	,vpm.NtbsSex
	,vpm.NtbsBirthDate
	,vpm.NtbsAddress
	,vpm.NtbsPostcode
	,vpm.ConfidenceLevel
FROM [dbo].vwPossibleMatch vpm*/