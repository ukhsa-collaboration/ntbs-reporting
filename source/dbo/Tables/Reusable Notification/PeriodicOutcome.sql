CREATE TABLE [dbo].[PeriodicOutcome]
(
	[PeriodicOutcomeId] INT IDENTITY(1,1) NOT NULL, 
    [NotificationId] INT NOT NULL, 
    [TimePeriod] SMALLINT NULL, 
    [OutcomeValue] NVARCHAR(50) NULL, 
    [DescriptiveOutcome] NVARCHAR(250) NULL,
    [IsFinal] BIT NULL, 
    CONSTRAINT [PK_PeriodicOutcome] PRIMARY KEY ([PeriodicOutcomeId])
)
