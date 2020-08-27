CREATE TABLE [dbo].[AntibioticLookup](
	[AntibioticOutputName] [nvarchar](50) NOT NULL,
	[AntibioticDescription] NVARCHAR(75) NOT NULL, 
    CONSTRAINT [PK_AntibioticLookup] PRIMARY KEY ([AntibioticOutputName])
) ON [PRIMARY]
GO