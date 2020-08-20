CREATE TABLE [dbo].[DeathLookup]
(
	[Id] INT IDENTITY(1,1) NOT NULL, 
    [DeathCode] NVARCHAR(30) NULL, 
    [DeathDescription] NVARCHAR(30) NULL, 
    CONSTRAINT [PK_DeathLookup] PRIMARY KEY ([Id])
)
