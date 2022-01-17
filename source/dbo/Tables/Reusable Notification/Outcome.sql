CREATE TABLE [dbo].[Outcome]
(
	[OutcomeId] [int] IDENTITY(1,1) NOT NULL, 
    [NotificationId] INT NOT NULL, 
    [NotificationStartDate] DATETIME NULL, 
   
    CONSTRAINT [PK_Outcome] PRIMARY KEY ([OutcomeId])
)
