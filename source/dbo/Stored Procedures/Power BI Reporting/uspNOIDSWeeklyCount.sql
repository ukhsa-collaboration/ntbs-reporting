/*on a Monday morning, count the number of rows in the NOIDS view
for the week before and store this in a table */
CREATE PROCEDURE [dbo].[uspGenerateNOIDSWeeklyCount]
AS
BEGIN TRY

	DECLARE @LastSunday DATE =  (SELECT MAX(DateValue) FROM [dbo].Calendar WHERE DateValue <= GETUTCDATE() AND DATENAME(dw, DateValue) = 'Sunday')

	--check to see if a value has already been stored this week (for the preceding week)
	IF NOT EXISTS
	(SELECT wc.ForWeekEnding
		FROM [dbo].[NOIDSWeeklyCount] wc
		WHERE wc.ForWeekEnding = @LastSunday)
	BEGIN
		INSERT INTO [dbo].NOIDSWeeklyCount(ForWeekEnding, RecordCount, RecordedOn)
			SELECT @LastSunday, COUNT(*), GETUTCDATE()
				FROM [dbo].[vwNOIDSExtract]
			WHERE NotificationDate <= @LastSunday
	END
END TRY
BEGIN CATCH
	THROW
END CATCH


RETURN 0
