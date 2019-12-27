CREATE PROCEDURE [dbo].[uspNotificationCultureResistanceSummary]
	
AS
	
	/*This will populate a new table, which gives a culture and resistance summary for each notification, built from the
	LabSpecimen summaries which are matched to the notification*/

	/*The table doesn't exist yet, but it will use queries like this to populate each field in turn*/
	SELECT Q2.NotificationID, Q3.ResultOutputName FROM
			--get the lowest ranked ISO result for each notification
			(SELECT nms.NotificationID, MIN (Q1.[Rank]) AS 'MinRank'
			FROM
				[dbo].[LabSpecimen] ls
			--innermost query creates a distinct list of result names and their rank
			INNER JOIN (SELECT DISTINCT rm.ResultOutputName, rm.[Rank]  FROM [dbo].ResultMapping rm) AS Q1 ON Q1.ResultOutputName = ls.ISO --dynamic SQL to change this field each time
			INNER JOIN [$(NTBS_Specimen_Matching)].[dbo].NotificationSpecimenMatch nms ON nms.ReferenceLaboratoryNumber = ls.ReferenceLaboratoryNumber
			--WHERE nms.NotificationID = '209772'
			GROUP BY nms.NotificationID) AS Q2
		INNER JOIN (SELECT DISTINCT rm.ResultOutputName, rm.[Rank]  FROM [dbo].ResultMapping rm) AS Q3 ON Q3.[Rank] = Q2.MinRank


RETURN 0
