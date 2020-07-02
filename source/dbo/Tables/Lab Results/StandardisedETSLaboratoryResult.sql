CREATE TABLE [dbo].[StandardisedETSLaboratoryResult] (
    [NotificationId]         BIGINT           NULL,
    [Id]                     [uniqueidentifier] NOT NULL,
    [OpieId]                 NVARCHAR (36)    NULL,
);


GO

CREATE INDEX [IX_StandardisedETSLaboratoryResult_NotificationId] ON [dbo].[StandardisedETSLaboratoryResult] ([NotificationId])

GO

CREATE INDEX [IX_StandardisedETSLaboratoryResult_OpieId] ON [dbo].[StandardisedETSLaboratoryResult] ([OpieId])
