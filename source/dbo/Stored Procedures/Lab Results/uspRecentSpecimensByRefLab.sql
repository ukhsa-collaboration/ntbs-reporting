CREATE PROCEDURE [dbo].[uspRecentSpecimensByRefLab]
	@RecentDate DATETIME = NULL
AS
	SELECT 
		ReferenceLaboratory, 
		COUNT(ReferenceLaboratoryNumber) AS NumberOfRecords 
	FROM
		[$(NTBS_Specimen_Matching)].[dbo].LabSpecimen
	WHERE EarliestRecordDate >= DATEADD(DAY, -3, @RecentDate)
	GROUP BY ReferenceLaboratory
RETURN 0
