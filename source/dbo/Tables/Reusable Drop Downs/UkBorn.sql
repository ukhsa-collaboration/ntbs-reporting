/***************************************************************************************************
Desc:    This contains the UkBorn drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[UkBorn](
	[UkBornId] [tinyint] IDENTITY(1,1) NOT NULL,
	[UkBorn] [varchar](10) NOT NULL

	CONSTRAINT [PK_UkBorn] PRIMARY KEY CLUSTERED (
		[UkBorn] ASC
	)
) ON [PRIMARY]
GO
