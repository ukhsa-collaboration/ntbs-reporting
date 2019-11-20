/***************************************************************************************************
Desc:    This contains the TreatmentOutcomeTimePeriod drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[TreatmentOutcomeTimePeriod] (
	[TreatmentOutcomeTimePeriodId] [tinyint] IDENTITY(1,1) NOT NULL,
	[TreatmentOutcomeTimePeriod] [varchar](50) NOT NULL

	CONSTRAINT [PK_TreatmentOutcomeTimePeriod] PRIMARY KEY CLUSTERED (
		[TreatmentOutcomeTimePeriodId] ASC
	)
) ON [PRIMARY]
GO
