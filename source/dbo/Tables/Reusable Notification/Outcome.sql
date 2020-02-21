CREATE TABLE [dbo].[Outcome]
(
	[OutcomeId] [tinyint] IDENTITY(1,1) NOT NULL, 
    [NotificationId] INT NOT NULL, 
    [TreatmentStartDate] DATETIME NULL, 
    [TreatmentOutcome12Months] VARCHAR(30) NULL, 
    [TreatmentOutcome12MonthsSubType] VARCHAR(30) NULL, 
    [TreatmentOutcome24Months] VARCHAR(30) NULL, 
    [TreatmentOutcome24MonthsSubType] VARCHAR(30) NULL, 
    [TreatmentOutcome36Months] VARCHAR(30) NULL,
    [TreatmentOutcome36MonthsSubType] VARCHAR(30) NULL, 
    [LastRecordedTreatmentOutcome] VARCHAR(30) NULL, 
   
    CONSTRAINT [PK_Outcome] PRIMARY KEY ([OutcomeId])
)
