CREATE TABLE [dbo].[MigrationAlert]
(
	NTBSNotificationId [nvarchar](30) NOT NULL,
	[MigrationRunId] [int] NOT NULL,
	[AlertType] [nvarchar](450) NOT NULL
)
