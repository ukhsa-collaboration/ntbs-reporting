CREATE VIEW [dbo].[vwConfirmedMatch]
	AS 
		SELECT nms.NotificationID, ls.* FROM [$(NTBS_Specimen_Matching)].[dbo].NotificationSpecimenMatch nms
		INNER JOIN dbo.LabSpecimen ls ON ls.ReferenceLaboratoryNumber = nms.ReferenceLaboratoryNumber
		WHERE nms.MatchType = 'Confirmed'
