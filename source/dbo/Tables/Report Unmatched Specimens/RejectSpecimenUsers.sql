CREATE TABLE [dbo].[RejectSpecimenUsers]
(
	[Id] INT NOT NULL PRIMARY KEY,
	[ReferenceLaboratoryNumber] NVARCHAR(50),
	[EventType] NVARCHAR(50),
	[RejectionTime] DATETIME2(7),
	[UserDisplayName] NVARCHAR(250),
	[NotificationId] int
)
