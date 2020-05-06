/*
This proc is intended to be run manually as a one-off job to populate a Calendar table for use in date processing
*/

CREATE PROCEDURE [dbo].[uspPopulateCalendarTable]
AS
    --first delete the existing table if it exists
    IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.tables WHERE table_name = 'Calendar')
			BEGIN
				TRUNCATE TABLE [dbo].Calendar
			END

    --start Calendar from 2000 in case we need to use it for very old data
    DECLARE @StartDate  date = '2000-01-01';
    
    --add 40 years' worth of dates into the table
    DECLARE @CutoffDate date = DATEADD(DAY, -1, DATEADD(YEAR, 40, @StartDate));

    --create sequence of numbers
    WITH seq(n) AS 
    (
      SELECT 0 UNION ALL SELECT n + 1 FROM seq
      WHERE n < DATEDIFF(DAY, @StartDate, @CutoffDate)
    ),
    --then a range of dates
    dateRange(dateField) AS 
    (
        SELECT DATEADD(DAY, n, @StartDate) FROM seq
    ),
    --and finally a formatted set of values for each date in the range
    sourceQuery AS
    (
          SELECT
            DateValue       = CONVERT(date, dateField),
            MonthValue      = DATEPART(MONTH, dateField),
	        PaddedMonthValue = FORMAT(DATEPART(MONTH, dateField), '00'),
	        YearValue         = DATEPART(YEAR, dateField),
	        YearMonthValue = CONCAT(DATEPART(YEAR, dateField), '-', FORMAT(DATEPART(MONTH, dateField), '00')),
            QuarterValue      = DATEPART(Quarter, dateField),
	        TertileValue =	 (CASE WHEN DATEPART(MONTH, dateField) < 5 THEN 1 WHEN DATEPART(MONTH, dateField) < 9 THEN 2 ELSE 3 END),
            FirstOfMonthValue = DATEFROMPARTS(YEAR(dateField), MONTH(dateField), 1),
	        LastOfMonthValue = EOMONTH(dateField),
            LastOfYearValue   = DATEFROMPARTS(YEAR(dateField), 12, 31),
            DayOfYearValue    = DATEPART(DAYOFYEAR, dateField),
	        ISOWeek			= DATEPART(ISO_WEEK,  dateField),
            PaddedISOWeek	= FORMAT(DATEPART(ISO_WEEK,  dateField),'00'),
	        ISOYear			= YEAR(DATEADD(day, 26 - DATEPART(isoww, dateField), dateField)),
	        ISOYearWeek		= CONCAT(YEAR(DATEADD(day, 26 - DATEPART(isoww, dateField), dateField)), '-', FORMAT(DATEPART(ISO_WEEK,  dateField),'00'))
	
          FROM dateRange
)

    --LOAD THIS DATA INTO A TABLE
    INSERT INTO dbo.Calendar SELECT * FROM sourceQuery
    OPTION (MAXRECURSION 0);
    
RETURN 0
