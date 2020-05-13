CREATE TABLE [dbo].[Calendar]
(
	[DateValue] [date] NOT NULL,
	[MonthValue] [int] NULL,
	[PaddedMonthValue] [nvarchar](100) NULL,
	[YearValue] [int] NULL,
	[YearMonthValue] [nvarchar](100) NULL,
	[QuarterValue] [int] NULL,
	[TertileValue] [int] NULL,
	[FirstOfMonthValue] [date] NULL,
	[LastOfMonthValue] [date] NULL,
	[LastOfYearValue] [date] NULL,
	[DayOfYearValue] [int] NULL,
	[ISOWeek] [int] NULL,
	[PaddedISOWeek] [nvarchar](100) NULL,
	[ISOYear] [int] NULL,
	[ISOYearWeek] [nvarchar](100) NULL, 
) 



GO

CREATE UNIQUE CLUSTERED INDEX PK_DateValue ON dbo.Calendar(DateValue);
