CREATE FUNCTION [dbo].[ufnGetMatchedSpecimen]
(
	@NTBSId int
)

RETURNS TABLE
AS

RETURN
SELECT 
	vcm.NotificationID AS 'NotificationId'
	,vcm.ReferenceLaboratoryNumber
	,vcm.SpecimenDate
	,vcm.SpecimenTypeCode
	,vcm.LaboratoryName
	,vcm.ReferenceLaboratory
	,vcm.Species

	,vcm.PatientNhsNumber AS 'LabNhsNumber'
	,vcm.PatientBirthDate AS 'LabBirthDate'
	,vcm.PatientName AS 'LabName'
	,vcm.PatientSex AS 'LabSex'
	,vcm.PatientAddress AS 'LabAddress'
	,vcm.PatientPostcode AS 'LabPostcode'

	,vcm.INH AS 'Isoniazid'
	,vcm.RIF AS 'Rifampicin'
	,vcm.PYR AS 'Pyrazinamide'
	,vcm.ETHAM AS 'Ethambutol'
	,vcm.AMINO AS 'Aminoglycocide'
	,vcm.QUIN AS 'Quinolone'
	,vcm.MDR
	,vcm.XDR
  
FROM [dbo].[vwConfirmedMatch] vcm
WHERE vcm.NotificationID = @NTBSId