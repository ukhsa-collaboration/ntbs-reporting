CREATE TABLE [dbo].[AntibioticMapping](
	[AntibioticCode] [nvarchar](50) NOT NULL,
	[IsWGS] [bit] NOT NULL,
	[AntibioticOutputName] [nvarchar](50) NOT NULL
) ON [PRIMARY]
GO