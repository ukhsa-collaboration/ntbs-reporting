CREATE VIEW [dbo].[vwAlert]
	AS
	SELECT 
		a.NotificationId,
		a.AlertId,
		a.AlertStatus,
		a.AlertType,
		a.ClosingUserId,
		a.ClosureDate,
		a.CreationDate,
		a.DuplicateId,
		a.SpecimenId,
		hd.TBServiceCode

  FROM [$(NTBS)].[dbo].Alert a
		LEFT OUTER JOIN [$(NTBS)].[dbo].[HospitalDetails] hd ON hd.NotificationId = a.NotificationId
