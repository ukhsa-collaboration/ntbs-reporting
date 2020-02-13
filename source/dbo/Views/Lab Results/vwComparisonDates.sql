/*this is a view for use in the specimen matching database, retrieving dates and DRP of interest when deciding if a specimen date falls within
the expected time period of treatment for a given notification*/
CREATE VIEW [dbo].[vwComparisonDates]
	AS

SELECT n.NotificationId, n.NotificationDate, drp.DrugResistanceProfileString AS DrugResistanceProfile, n.NotificationDate as 'OutcomeDate'
    FROM [$(NTBS)].[dbo].[Notification] n
	INNER JOIN [$(NTBS)].[dbo].DrugResistanceProfile drp ON drp.NotificationId = n.NotificationId
	

