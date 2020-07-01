CREATE TABLE [dbo].[User]
(
	--this is a copy of the NTBS User table which will be populated each night
    --having a local copy allows it to be queried implicitly by the report end user
    --as their identity is passed through to the database (which would require the NTBS User table to be
    --made available to PUBLIC)
    [Username]      NVARCHAR (64)  NOT NULL,
    [GivenName]     NVARCHAR (64)  NULL,
    [FamilyName]    NVARCHAR (64)  NULL,
    [AdGroups]      NVARCHAR (MAX) NULL,
    [DisplayName]   NVARCHAR (64)  NULL,
    [IsActive]      BIT            DEFAULT ((0)) NOT NULL,
    [IsCaseManager] BIT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([Username] ASC)
)
