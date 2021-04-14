CREATE TABLE [dbo].[RecordRegister](
	-- This primary key
	[RegisterId] [int] IDENTITY(1,1) NOT NULL,
	-- Global (ETS, LTBR, NTBS encompassing) primary key
	[NotificationId] [int] NOT NULL,
	--Source of record
	[SourceSystem] [varchar](10) NOT NULL,
	[NotificationDate] [date] NOT NULL,
	[TBServiceCode] [varchar] (10) NULL,
	[LocalAuthorityCode] [varchar](15) NULL,
	[ResidencePhecCode] [varchar] (15) NULL,
	[TreatmentPhecCode] [varchar] (15) NULL,
	[ClusterId] [varchar](20) NULL,
	[Denotified] BIT NULL, 
    CONSTRAINT [PK_RecordRegister] PRIMARY KEY CLUSTERED (
		[RegisterId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_RecordRegister_NotificationId ON dbo.RecordRegister(NotificationId)
GO
CREATE NONCLUSTERED INDEX IX_RecordRegister_NotificationDate ON dbo.RecordRegister(NotificationDate)
GO
