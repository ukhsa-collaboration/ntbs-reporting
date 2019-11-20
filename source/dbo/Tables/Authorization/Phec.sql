/***************************************************************************************************
Desc:    This contains the PHEC groups that NTBS R1 users must belong to to have record 
         viewing access.


         
**************************************************************************************************/

CREATE TABLE [dbo].[Phec](
	[PhecId] [tinyint] IDENTITY(1,1) NOT NULL,
	[PhecCode] [nvarchar](50) NOT NULL,
	[PhecName] [nvarchar](50) NOT NULL,
	[SortOrder] [tinyint] NOT NULL

	CONSTRAINT [PK_Phec] PRIMARY KEY CLUSTERED (
		[PhecId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_Phec_PhecCode ON dbo.Phec(PhecCode)
GO
CREATE NONCLUSTERED INDEX IX_Phec_PhecName ON dbo.Phec(PhecName)
GO
CREATE NONCLUSTERED INDEX IX_Phec_SortOrder ON dbo.Phec(SortOrder)
GO
