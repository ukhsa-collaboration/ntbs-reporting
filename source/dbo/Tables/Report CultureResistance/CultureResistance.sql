/***************************************************************************************************
Desc:    This contains the pre-calculated figures for the "Culture And Resistance" report that get
         re-generated every night.


         
**************************************************************************************************/

CREATE TABLE [dbo].[CultureResistance](
	[CultureResistanceId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationId] [uniqueidentifier] NOT NULL,
	[CulturePositiveCases] [tinyint] NOT NULL DEFAULT(0),
	[NonCulturePositiveCases] [tinyint] NOT NULL DEFAULT(0),
	[SensitiveToAll4FirstLineDrugs] [tinyint] NOT NULL DEFAULT(0),
	[InhRes] [tinyint] NOT NULL DEFAULT(0),
	[Other] [tinyint] NOT NULL DEFAULT(0),
	[MdrRr] [tinyint] NOT NULL DEFAULT(0),
	[Xdr] [tinyint] NOT NULL DEFAULT(0),
	[IncompleteDrugResistanceProfile] [tinyint] NOT NULL DEFAULT(0)

	CONSTRAINT [PK_CultureResistance] PRIMARY KEY CLUSTERED (
		[CultureResistanceId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_CultureResistance_NotificationId ON dbo.CultureResistance(NotificationId)
GO
