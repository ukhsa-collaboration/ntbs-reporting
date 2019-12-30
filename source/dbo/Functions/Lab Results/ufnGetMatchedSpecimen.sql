CREATE FUNCTION [dbo].[ufnGetMatchedSpecimen]
(
	@NTBSId int
)

RETURNS TABLE
AS

RETURN
SELECT vcm.NotificationId
      ,vcm.ReferenceLaboratoryNumber
	  ,vcm.SpecimenDate
	  ,vcm.SpecimenTypeCode
	  ,vcm.LaboratoryName
	  ,vcm.ReferenceLaboratory
	  ,vcm.Species
	  ,vcm.INH AS 'Isoniazid'
	  ,vcm.RIF AS 'Rifampicin'
	  ,vcm.PYR AS 'Pyrazinamide'
	  ,vcm.ETHAM AS 'Ethambutol'
	  ,vcm.AMINO AS 'Aminoglycocide'
	  ,vcm.QUIN AS 'Quinolone'
	  ,vcm.MDR
	  ,vcm.XDR
	  ,vcm.PatientNhsNumber
	  ,vcm.PatientBirthDate
	  ,vcm.PatientName
	  ,vcm.PatientSex
	  ,vcm.PatientAddress
	  ,vcm.PatientPostcode
      
  FROM [dbo].[vwConfirmedMatch] vcm
  WHERE vcm.NotificationId = @NTBSId