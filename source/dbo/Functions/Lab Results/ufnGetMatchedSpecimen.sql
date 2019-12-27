CREATE FUNCTION [dbo].[ufnGetMatchedSpecimen]
(
	@NTBSId int
)

RETURNS TABLE
AS

RETURN
SELECT rn.EtsId
      ,ls.ReferenceLaboratoryNumber
	  ,ls.SpecimenDate
	  ,ls.SpecimenTypeCode
	  ,ls.LaboratoryName
	  ,ls.ReferenceLaboratory
	  ,ls.Species
	  ,ls.ISO AS 'Isoniazid'
	  ,ls.RIF AS 'Rifampicin'
	  ,ls.PYR AS 'Pyrazinamide'
	  ,ls.ETHAM AS 'Ethambutol'
	  ,ls.AMINO AS 'Aminoglycoside'
	  ,ls.QUIN AS 'Quinolone'
	  ,ls.MDR
	  ,ls.XDR
	  ,ls.PatientNhsNumber
	  ,ls.PatientBirthDate
	  ,ls.PatientName
	  ,ls.PatientSex
	  ,ls.PatientAddress
	  ,ls.PatientPostcode
      
  FROM dbo.ReusableNotification --placeholder for NTBS Notification Table
	rn 
  LEFT OUTER JOIN [$(NTBS_Specimen_Matching)].[dbo].NotificationSpecimenMatch nms ON nms.NotificationID = rn.EtsId
	AND nms.MatchType = 'Confirmed'
  LEFT OUTER JOIN [dbo].[LabSpecimen] ls ON ls.ReferenceLaboratoryNumber = nms.ReferenceLaboratoryNumber
  WHERE rn.EtsId = @NTBSId