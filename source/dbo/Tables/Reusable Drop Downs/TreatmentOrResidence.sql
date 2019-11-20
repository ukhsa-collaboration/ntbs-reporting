/***************************************************************************************************
Desc:    This contains the TreatmentOrResidence drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[TreatmentOrResidence](
	[TreatmentOrResidenceId] [tinyint] IDENTITY(1,1) NOT NULL,
	[TreatmentOrResidence] [varchar](50) NOT NULL

	CONSTRAINT [PK_TreatmentOrResidence] PRIMARY KEY CLUSTERED (
		[TreatmentOrResidenceId] ASC
	)
) ON [PRIMARY]
GO
