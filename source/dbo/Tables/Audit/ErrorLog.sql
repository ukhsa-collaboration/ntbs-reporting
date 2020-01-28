CREATE TABLE [dbo].[ErrorLog]
(
	[Id] Int IDENTITY(1,1) NOT NULL, 
    [ErrorDateTime] DATETIME NOT NULL DEFAULT GETUTCDATE(),
    [UserName] NVARCHAR(50) NULL, 
    [ErrorNumber] NVARCHAR(50) NULL, 
    [ErrorMessage] NVARCHAR(1000) NULL, 
    [ProcName] NVARCHAR(100) NULL, 
    [LineNumber] NVARCHAR(10) NULL
	 CONSTRAINT [PK_ErrorLog] PRIMARY KEY CLUSTERED (
		[Id] ASC
	)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_ErrorLog_ErrorDateTime ON dbo.ErrorLog(ErrorDateTime)
GO
CREATE NONCLUSTERED INDEX [IX_ErrorLog_UserName] ON [dbo].[ErrorLog] (UserName)
GO