/***************************************************************************************************
Desc:    This contains the SocialRiskFactors drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[SocialRiskFactors](
	[SocialRiskFactorId] [tinyint] IDENTITY(1,1) NOT NULL,
	[SocialRiskFactor] [varchar](40) NOT NULL

	CONSTRAINT [PK_SocialRiskFactors] PRIMARY KEY CLUSTERED (
		[SocialRiskFactorId] ASC
	)
) ON [PRIMARY]
GO
