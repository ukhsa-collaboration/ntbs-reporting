/***************************************************************************************************
Desc:    This contains the pre-calculated figures for the "Outcome Summary" report that get
         re-generated every night.


         
**************************************************************************************************/

CREATE TABLE [dbo].[OutcomeSummary](
	[OutcomeSummaryId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationId] [int] NOT NULL,
	[TreatmentCompletedLastOutcome] [tinyint] NOT NULL DEFAULT(0),
	[DiedLastOutcome] [tinyint] NOT NULL DEFAULT(0),
	[LostToFollowUpLastOutcome] [tinyint] NOT NULL DEFAULT(0),
	[StillOnTreatmentLastOutcome] [tinyint] NOT NULL DEFAULT(0),
	[TreatmentStoppedLastOutcome] [tinyint] NOT NULL DEFAULT(0),
	[NotEvaluatedLastOutcome] [tinyint] NOT NULL DEFAULT(0),
	[UnknownLastOutcome] [tinyint] NOT NULL DEFAULT(0),
	[TreatmentCompleted12Month] [tinyint] NOT NULL DEFAULT(0),
	[Died12Month] [tinyint] NOT NULL DEFAULT(0),
	[LostToFollowUp12Month] [tinyint] NOT NULL DEFAULT(0),
	[StillOnTreatment12Month] [tinyint] NOT NULL DEFAULT(0),
	[TreatmentStopped12Month] [tinyint] NOT NULL DEFAULT(0),
	[NotEvaluated12Month] [tinyint] NOT NULL DEFAULT(0),
	[Unknown12Month] [tinyint] NOT NULL DEFAULT(0),
	[TreatmentCompleted24Month] [tinyint] NOT NULL DEFAULT(0),
	[Died24Month] [tinyint] NOT NULL DEFAULT(0),
	[LostToFollowUp24Month] [tinyint] NOT NULL DEFAULT(0),
	[StillOnTreatment24Month] [tinyint] NOT NULL DEFAULT(0),
	[TreatmentStopped24Month] [tinyint] NOT NULL DEFAULT(0),
	[NotEvaluated24Month] [tinyint] NOT NULL DEFAULT(0),
	[Unknown24Month] [tinyint] NOT NULL DEFAULT(0),
	[TreatmentCompleted36Month] [tinyint] NOT NULL DEFAULT(0),
	[Died36Month] [tinyint] NOT NULL DEFAULT(0),
	[LostToFollowUp36Month] [tinyint] NOT NULL DEFAULT(0),
	[StillOnTreatment36Month] [tinyint] NOT NULL DEFAULT(0),
	[TreatmentStopped36Month] [tinyint] NOT NULL DEFAULT(0),
	[NotEvaluated36Month] [tinyint] NOT NULL DEFAULT(0),
	[Unknown36Month] [tinyint] NOT NULL DEFAULT(0)


	CONSTRAINT [PK_OutcomeSummary] PRIMARY KEY CLUSTERED (
		[OutcomeSummaryId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_OutcomeSummary_NotificationId ON dbo.OutcomeSummary(NotificationId)
GO
