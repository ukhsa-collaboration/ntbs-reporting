CREATE TABLE [dbo].[UnmatchedSpecimensLinkedNotifications]
(
	[ReferenceLaboratoryNumber] NVARCHAR(50) NOT NULL PRIMARY KEY,
	[NotificationLinkReason] NVARCHAR(255),
	[NotificationID] INT,
	[NotificationStatus] NVARCHAR(30),
	[NhsNumber] NVARCHAR(10),
	[Birthdate] DATETIME2(7),
	[Name] NVARCHAR(255),
	[Sex] NVARCHAR (200),
	[Address] NVARCHAR (150),
	[Postcode] NVARCHAR(10),
	[RegionCode] NVARCHAR(50)
)
