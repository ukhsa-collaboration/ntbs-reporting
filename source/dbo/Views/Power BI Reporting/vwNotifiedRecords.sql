/*This view will be the basis for aggregate counts, so will exclude denotified records*/

CREATE VIEW [dbo].[vwNotifiedRecords]
	AS 
	SELECT 
		rr.NotificationId, 
		rr.NotificationDate, 
		rr.TBServiceCode,
		rr.LocalAuthorityCode,
		rr.SourceSystem
	FROM [dbo].[RecordRegister] rr
	WHERE rr.Denotified = 0