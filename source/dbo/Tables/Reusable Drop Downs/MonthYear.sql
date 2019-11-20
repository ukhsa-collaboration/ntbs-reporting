/***************************************************************************************************
Desc:    This contains the MonthYear drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[MonthYear](
	[MonthYearId] [varchar](10) NOT NULL,
	[MonthYear] [varchar](10) NOT NULL

	CONSTRAINT [PK_MonthYear] PRIMARY KEY CLUSTERED (
		[MonthYearId] ASC
	)
) ON [PRIMARY]
GO
