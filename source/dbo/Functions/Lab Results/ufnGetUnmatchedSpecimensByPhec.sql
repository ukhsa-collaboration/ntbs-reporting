/*CREATE FUNCTION [dbo].[ufnGetUnmatchedSpecimensByPhec] 
(	
	--comma-separated list to be split using select value from STRING_SPLIT
	@Phec VARCHAR(200)		=	NULL
)

RETURNS TABLE 
AS

RETURN 
	--we want to return all specimens with a possible match in the PHECs supplied
	--however, for each of these specimens, we want to return all possible matches for them, including with notifications NOT
	--in the PHECs supplied. This means the user will see all possible matches for specimens where at least one of the matches
	--is a notification in their own PHEC/group of PHEC, to prevent people from just selecting the one match that relates to
	--their own PHEC

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
FROM [dbo].vwPossibleMatch vpm
	WHERE vpm.ReferenceLaboratoryNumber IN 
		(SELECT DISTINCT ReferenceLaboratoryNumber FROM [dbo].vwPossibleMatch WHERE [PHECCode] IN 
			(SELECT TRIM(VALUE) FROM STRING_SPLIT(@Phec, ',')))*/