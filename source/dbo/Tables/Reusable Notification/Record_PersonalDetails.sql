CREATE TABLE [dbo].[Record_PersonalDetails](
	-- This primary key
	[PersonalDetailsId] [int] IDENTITY(1,1) NOT NULL,

	-- Global (ETS, LTBR, NTBS encompassing) primary key
	[NotificationId] [int] NOT NULL,
	[NhsNumber] [nvarchar](50) NULL,
	[Forename] [nvarchar](50) NULL,
	[Surname] [nvarchar](50) NULL,
	[DateOfBirth] [date] NULL,
	[Postcode] [nvarchar](20) null,
	

	 CONSTRAINT [PK_Record_PersonalDetails] PRIMARY KEY CLUSTERED (
		[PersonalDetailsId] ASC
	), 
    CONSTRAINT [FK_Record_PersonalDetails_ToRecordRegister] FOREIGN KEY ([NotificationId]) REFERENCES [RecordRegister]([NotificationId])
) ON [PRIMARY]
GO

