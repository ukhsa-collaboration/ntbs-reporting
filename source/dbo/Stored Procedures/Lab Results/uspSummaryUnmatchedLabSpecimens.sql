/*This returns a summary of the unmatched lab specimens within the reporting period, i.e. current year +
last three complete years*/

CREATE PROCEDURE [dbo].[uspSummaryUnmatchedLabSpecimens]
AS
	SELECT DISTINCT 
		DATEPART(YEAR, Q1.SpecimenDate) AS SpecimenYear, 
		COUNT(Q1.ReferenceLaboratoryNumber) AS TotalNumberofRecords
	FROM
		(SELECT DISTINCT
			ls.[ReferenceLaboratoryNumber]
			,[SpecimenDate]
		FROM [$(NTBS_Specimen_Matching)].[dbo].[LabSpecimen] ls
		WHERE ls.ReferenceLaboratoryNumber NOT IN
			(SELECT ReferenceLaboratoryNumber 
			FROM [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch]
			WHERE MatchType = 'Confirmed')
		AND ls.ReferenceLaboratoryNumber NOT IN
			(SELECT [ReferenceLaboratoryNumber]
			FROM [$(NTBS_Specimen_Matching)].[dbo].[EtsSpecimenMatch])
		) AS Q1
	INNER JOIN [dbo].[vwNotificationYear] ny ON ny.NotificationYear = DATEPART(YEAR, Q1.SpecimenDate)
	GROUP BY DATEPART(YEAR, Q1.SpecimenDate) 
	ORDER BY DATEPART(YEAR, Q1.SpecimenDate)  DESC
RETURN 0
