CREATE TABLE [dbo].[RejectedSpecimen]
(
	[Id] INT NOT NULL PRIMARY KEY,
	[ReferenceLaboratoryNumber] NVARCHAR(50),
	[EventType] NVARCHAR(50),
	[RejectionDate] DATETIME2(7),
	[UserDisplayName] NVARCHAR(250),
	[NotificationId] int
)
