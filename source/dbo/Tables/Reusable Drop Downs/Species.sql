/***************************************************************************************************
Desc:    This contains the Species drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[Species](
	[SpeciesId] [tinyint] IDENTITY(1,1) NOT NULL,
	[Species] [varchar](50) NOT NULL

	CONSTRAINT [PK_Species] PRIMARY KEY CLUSTERED (
		[SpeciesId] ASC
	)
) ON [PRIMARY]
GO
