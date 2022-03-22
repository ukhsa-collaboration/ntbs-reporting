CREATE TABLE [dbo].[UnmatchedSpecimensLinkedNotifications]
(
	[ReferenceLaboratoryNumber] NVARCHAR(50) NOT NULL PRIMARY KEY,
	[NotificationLinkReason] NVARCHAR(255),
	[RejectionDate] DATETIME2(7),
	[User] NVARCHAR(256),
	[NotificationID] INT,
	[Denotified] NVARCHAR(30),
	[NhsNumber] NVARCHAR(20),
	[BirthDate] DATE,
	[FamilyName] NVARCHAR(50),
	[GivenName] NVARCHAR(50),
	[Sex] VARCHAR (10),
	[Postcode] NVARCHAR(20),
	[RegionCode] VARCHAR(50)
)
