/***************************************************************************************************
Desc:    This contains the Resistant drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[Resistant] (
	[ResistantId] [tinyint] IDENTITY(1,1) NOT NULL,
	[ResistantDesc] [varchar](50) NOT NULL

	CONSTRAINT [PK_Resistant] PRIMARY KEY CLUSTERED (
		[ResistantId] ASC
	)
) ON [PRIMARY]
GO
