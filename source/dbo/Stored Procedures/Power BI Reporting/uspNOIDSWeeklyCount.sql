/*on a Monday morning, count the number of rows in the NOIDS view
for the week before and store this in a table */
CREATE PROCEDURE [dbo].[uspGenerateNOIDSWeeklyCount]
AS
	DECLARE @ThisWeek VARCHAR(10) =  (SELECT ISOYearWeek FROM [dbo].Calendar WHERE DateValue = CONVERT(DATE, GETUTCDATE()))
	DECLARE @LastSunday DATE =  (SELECT MAX(DateValue) FROM [dbo].Calendar WHERE DateValue <= GETUTCDATE() AND DATENAME(dw, DateValue) = 'Sunday')

	--check to see if a value has already been stored for this week
	IF NOT EXISTS
	(SELECT wc.DateValue 
		FROM [dbo].[NOIDSWeeklyCount] wc
			INNER JOIN [dbo].[Calendar] c ON c.DateValue = wc.DateValue
		WHERE c.ISOYearWeek = @ThisWeek)
	BEGIN
		INSERT INTO [dbo].NOIDSWeeklyCount(DateValue, RecordCount)
			SELECT GETUTCDATE(), COUNT(*)
				FROM [dbo].[vwNOIDSExtract]
			WHERE NotificationDate <= @LastSunday

	END


RETURN 0
