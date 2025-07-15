CREATE TABLE [dbo].[UnmatchedSpecimensLinkedNotifications]
(
	[ReferenceLaboratoryNumber] NVARCHAR(50) NOT NULL,
	[NotificationLinkReason] NVARCHAR(255),
	[RejectionDate] DATETIME2(7),
	[User] NVARCHAR(256),
	[NotificationID] INT,
	[NotificationDate] [datetime2](7),
	[NotificationStatus] NVARCHAR(30),
	[NhsNumber] NVARCHAR(10),
	[ChiNumber] NVARCHAR(10),
	[BirthDate] DATETIME2(7),
	[FamilyName] NVARCHAR(35),
	[GivenName] NVARCHAR(35),
	[Sex] NVARCHAR (200),
	[Address] NVARCHAR (150),
	[Postcode] NVARCHAR(10),
	[RegionCode] NVARCHAR(50),
	TreatmentStartDate [datetime2](7) 
)
