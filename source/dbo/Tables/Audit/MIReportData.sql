CREATE TABLE [dbo].[MIReportData]
(
	[Id] INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[ExecutionDateTime] datetime NOT NULL,
	[UserName] NVARCHAR(260) NOT NULL,
	[UserAdGroup] NVARCHAR(300) NULL,
	[WeekNumber] NVARCHAR(7) NULL,
	[ReportID] UNIQUEIDENTIFIER NOT NULL,
	[DateRetrieved] datetime NULL

)
