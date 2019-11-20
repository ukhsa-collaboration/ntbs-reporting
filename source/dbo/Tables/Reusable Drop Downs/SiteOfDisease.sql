/***************************************************************************************************
Desc:    This contains the SiteOfDisease drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[SiteOfDisease](
	[SiteOfDiseaseId] [tinyint] IDENTITY(1,1) NOT NULL,
	[SiteOfDisease] [varchar](50) NOT NULL

	CONSTRAINT [PK_SiteOfDisease] PRIMARY KEY CLUSTERED (
		[SiteOfDiseaseId] ASC
	)
) ON [PRIMARY]
GO
