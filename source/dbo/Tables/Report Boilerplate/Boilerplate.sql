/***************************************************************************************************
Desc:    This contains the pre-calculated figures for the "Boilerplate" report that get re-generated
         every night.


         
**************************************************************************************************/

CREATE TABLE [dbo].[Boilerplate] (
	[BoilerplateId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationId] [int]     NOT NULL,
	[BoilerplateCalculationNo1] [int] NULL,
	[BoilerplateCalculationNo2] [int] NULL

	CONSTRAINT [PK_Boilerplate] PRIMARY KEY CLUSTERED (
		[BoilerplateId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_Boilerplate_NotificationId ON dbo.Boilerplate(NotificationId)
GO
