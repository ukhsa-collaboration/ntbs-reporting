/***************************************************************************************************
Desc:    This contains the footer text that gets calculated over-night and every SSRS report displays 
         underneath the actual report.


         
**************************************************************************************************/

CREATE TABLE [dbo].[FooterText](
	[FooterTextId] [tinyint] NOT NULL,
	[FooterText] [varchar](1000) NULL

	CONSTRAINT [PK_FooterText] PRIMARY KEY CLUSTERED (
		[FooterTextId] ASC
	)
) ON [PRIMARY]
GO
