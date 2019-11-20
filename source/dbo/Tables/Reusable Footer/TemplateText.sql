/***************************************************************************************************
Desc:    This contains template text, so for example, the footer text template with placeholders
         for the footer text calculations to fill in that are scheduled to happen over-night.


         
**************************************************************************************************/

CREATE TABLE [dbo].[TemplateText] (
	[TemplateTextId] [int] IDENTITY(1,1) NOT NULL,
	[Desc] [varchar](100) NOT NULL,
	[Text] [varchar](1000) NOT NULL

	CONSTRAINT [PK_TemplateText] PRIMARY KEY CLUSTERED (
		[TemplateTextId] ASC
	)
) ON [PRIMARY]
GO
