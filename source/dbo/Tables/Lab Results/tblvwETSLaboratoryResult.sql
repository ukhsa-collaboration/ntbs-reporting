CREATE TABLE [dbo].[tblvwETSLaboratoryResult] (
    [NotificationId]         BIGINT           NULL,
    [Id]                     UNIQUEIDENTIFIER NOT NULL,
    [LaboratoryCategoryId]   UNIQUEIDENTIFIER NOT NULL,
    [SpecimenTypeId]         UNIQUEIDENTIFIER NOT NULL,
    [Result]                 TINYINT          NOT NULL,
    [MycobacterialSpeciesId] UNIQUEIDENTIFIER NULL,
    [StatusSet]              DATETIME         NULL,
    [Received]               DATETIME         NULL,
    [OpieId]                 NVARCHAR (36)    NULL,
    [LaboratoryId]           UNIQUEIDENTIFIER NULL,
    [AuditUserId]            UNIQUEIDENTIFIER NOT NULL,
    [AuditCreate]            DATETIME         NOT NULL,
    [AuditDelete]            DATETIME         NULL,
    [AuditAlter]             DATETIME         NOT NULL,
    [AutoMatched]            BIT              NULL
);

