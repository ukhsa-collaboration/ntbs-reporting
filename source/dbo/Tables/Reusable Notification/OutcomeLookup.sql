CREATE TABLE [dbo].[OutcomeLookup]
(
	[Id] [tinyint] IDENTITY(1,1) NOT NULL, 
    [OutcomeCode] NVARCHAR(30) NULL, 
    [OutcomeDescription] NVARCHAR(30) NULL, 
    CONSTRAINT [PK_OutcomeLookup] PRIMARY KEY ([Id])
)
