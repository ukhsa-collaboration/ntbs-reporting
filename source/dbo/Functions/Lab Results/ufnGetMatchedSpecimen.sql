CREATE FUNCTION [dbo].[ufnGetMatchedSpecimen]
(
	@NTBSId int
)
RETURNS TABLE
AS
BEGIN


--first go to the matching table to get all records corresponding to the passed-in NTBS ID



-- then many of the required fields can be returned from the table [reporting].[dbo].LabSpecimen
-- the rest need to come from a companion table or an extension to the LabSpecimen table at least which includes the fields
-- for the drug resistance fields

/*returns
LaboratoryReferenceNumber
SpecimenDate
SpecimenType
Species
Status Positive @Tehreem Mohiyuddin I don’t know what this is - I guess if the specimen is positive but no other info is available, this is what will be shown?
Isoniazid
Rifampicin
Ethambutol
Pyrazinamide
MDR
Aminoglycocide
Quinolone
XDR
Patient NHS number
Patient Name
Patient date of birth
Patient sex
Patient address
Patient postcode*/

 





	RETURN @param1 + @param2
END
