/***************************************************************************************************
Desc:    This table contains logs/audits for each notification record that has been viewed 
         together with information about the user, who has viewed it.


         
**************************************************************************************************/

CREATE TABLE [dbo].[AccessAudit] (
    [AccessAuditId]        INT              IDENTITY (1, 1) NOT NULL,
    [ReportName]     VARCHAR(50)      NOT NULL,
    [AccessDate]     DATETIME         NOT NULL,
    [User]           NVARCHAR(128)    NOT NULL,
    [Group]          VARCHAR(500)     NOT NULL,
    [NotificationId] UNIQUEIDENTIFIER NOT NULL,
    [EtsId]          BIGINT           NULL

	CONSTRAINT [PK_AccessAudit] PRIMARY KEY CLUSTERED (
		[AccessAuditId] ASC
	)
)
GO

-- WARNING: These indexes will slow down each "Line List" report, so only apply the indexes absolutetely neccessary, and then only one-by-one !!!
/* CREATE NONCLUSTERED INDEX IX_AccessAudit_AccessDate ON dbo.AccessAudit(AccessDate)
GO
CREATE NONCLUSTERED INDEX IX_AccessAudit_User ON dbo.AccessAudit([User])
GO
CREATE NONCLUSTERED INDEX IX_AccessAudit_EtsId ON dbo.AccessAudit(EtsId)
GO */
