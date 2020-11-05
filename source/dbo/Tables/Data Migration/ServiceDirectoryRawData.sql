CREATE TABLE [dbo].[ServiceDirectoryRawData]
(
	[Forename] [nvarchar](50) NOT NULL,
	[Surname] [nvarchar](50) NOT NULL,
	[Email_address_1] [nvarchar](50) NOT NULL,
	[Email_address_2] [nvarchar](50) NULL,
	[Position] [nvarchar](100) NULL,
	[Telephone_1] [nvarchar](50) NULL,
	[Telephone_2] [nvarchar](50) NULL,
	[ETS_username] [nvarchar](50) NULL,
	[SheetName] [nvarchar](50) NOT NULL,
	[HPT_Note] [nvarchar](150) NULL
) ON [PRIMARY]
