CREATE TABLE [dbo].[MultiSystemTransfers]
(
	[NotificationID] BIGINT NOT NULL PRIMARY KEY,
	[NotificationDate] DATETIME,
	[SourceSystem] NVARCHAR(5),
	[ETSID] NVARCHAR(50),
	[Requester] NVARCHAR(150),
	[RequestedOrganisation] NVARCHAR(150),
	[CreatedDate] DATETIME
)
