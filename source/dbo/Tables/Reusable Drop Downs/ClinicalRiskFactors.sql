/***************************************************************************************************
Desc:    This contains the ClinicalRiskFactors drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[ClinicalRiskFactors](
	[ClinicalRiskFactorId] [tinyint] IDENTITY(1,1) NOT NULL,
	[ClinicalRiskFactor] [varchar](30) NOT NULL

	CONSTRAINT [PK_ClinicalRiskFactors] PRIMARY KEY CLUSTERED (
		[ClinicalRiskFactorId] ASC
	)
) ON [PRIMARY]
