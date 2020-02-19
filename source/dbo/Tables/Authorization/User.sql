CREATE TABLE [dbo].[User] (
    [Username]      NVARCHAR (64)  NOT NULL,
    [GivenName]     NVARCHAR (64)  NULL,
    [FamilyName]    NVARCHAR (64)  NULL,
    [AdGroups]      NVARCHAR (MAX) NULL,
    [DisplayName]   NVARCHAR (64)  NULL,
    [IsActive]      BIT            DEFAULT ((0)) NOT NULL,
    [IsCaseManager] BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([Username] ASC)
);

