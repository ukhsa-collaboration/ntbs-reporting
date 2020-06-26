/*
Returns consolidated information about a lab specimen, summarising data from 
local copies of LabBase data
*/

CREATE FUNCTION [dbo].[ufnGetSpecimenInfo](@RefLabNumber NVARCHAR(50))
RETURNS @specimenInfo TABLE 
(
    -- Columns returned by the function
    RefLabNumber NVARCHAR(50) PRIMARY KEY NOT NULL, 
    SpecimenTypeCode NVARCHAR(255) NULL, 
    IdentityColumn INT NULL, 
    SpecimenDate DATE NULL, 
    Species NVARCHAR(50) NULL
)
AS
BEGIN

  DECLARE 
	@SpecimenTypeCode nvarchar(255) = NULL, 
	@IdentityColumn INT = 0, 
	@SpecimenDate DATE, 
	@Species NVARCHAR(50) = NULL;

	SELECT TOP(1) @SpecimenTypeCode = SampleName 
	FROM [dbo].[LabSpecimen] ls
		INNER JOIN [dbo].[StandardisedLabbaseSpecimen] lbs on ls.ReferenceLaboratoryNumber = lbs.ReferenceLaboratoryNumber
		LEFT OUTER JOIN [dbo].SampleMapping sm ON lbs.SpecimenTypeCode = sm.SampleName
	WHERE ls.ReferenceLaboratoryNumber = @RefLabNumber
	ORDER BY sm.SampleRank 


	SELECT @IdentityColumn = MAX(lbs.[IdentityColumn]), @SpecimenDate = MIN(lbs.SpecimenDate) 
	FROM [dbo].[LabSpecimen] ls
		INNER JOIN [dbo].[StandardisedLabbaseSpecimen] lbs on ls.ReferenceLaboratoryNumber = lbs.ReferenceLaboratoryNumber
	WHERE ls.ReferenceLaboratoryNumber = @RefLabNumber

	SELECT TOP(1) @Species = o.OrganismName FROM [dbo].[LabSpecimen] ls
		INNER JOIN [dbo].[StandardisedLabbaseSpecimen] lbs on ls.ReferenceLaboratoryNumber = lbs.ReferenceLaboratoryNumber
		INNER JOIN [$(Labbase2)].[dbo].[Anonymised] a on a.LabDataID = lbs.LabDataID
		INNER JOIN [dbo].OrganismNameMapping om on om.OrganismName = a.OrganismName
		INNER JOIN [dbo].Organism o ON o.OrganismId = om.OrganismId
	WHERE ls.ReferenceLaboratoryNumber = @RefLabNumber
	ORDER BY o.SortOrder

	INSERT INTO @specimenInfo
		SELECT @RefLabNumber, @SpecimenTypeCode, @IdentityColumn, @SpecimenDate, @Species
	RETURN
END
GO