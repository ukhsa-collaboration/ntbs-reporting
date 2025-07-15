﻿CREATE TABLE [dbo].[Record_PersonalDetails](
	-- This primary key
	[PersonalDetailsId] [int] IDENTITY(1,1) NOT NULL,

	-- Global (ETS, LTBR, NTBS encompassing) primary key
	[NotificationId] [int] NOT NULL,
	[NhsNumber] [nvarchar](20) NULL,
	[NhsNumberToLookup] [nvarchar](20) NULL,
	[ChiNumber] [nvarchar](20) NULL,
	[GivenName] [nvarchar](50) NULL,
	[FamilyName] [nvarchar](50) NULL,
	[Initials] [nvarchar] (5) NULL,
	[DateOfBirth] [date] NULL,
	[Postcode] [nvarchar](20) null,
	

	 [PostcodeToLookup] NVARCHAR(20) NULL, 
    CONSTRAINT [PK_Record_PersonalDetails] PRIMARY KEY CLUSTERED (
		[PersonalDetailsId] ASC
	) 
) ON [PRIMARY]
GO

