/***************************************************************************************************
Desc:    This contains the PHEC/AD group allocations that NTBS R1 users must belong to to have record 
         viewing access.


         
**************************************************************************************************/

CREATE TABLE [dbo].[PhecAdGroup](
	[PhecAdGroupId] [tinyint] IDENTITY(1,1) NOT NULL,
	[PhecId] [tinyint]  NOT NULL,
	[AdGroupId] [tinyint] NOT NULL

	CONSTRAINT [PK_PhecAdGroup] PRIMARY KEY CLUSTERED (
		[PhecAdGroupId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_PhecAdGroup_PhecId ON dbo.PhecAdGroup(PhecId)
GO
CREATE NONCLUSTERED INDEX IX_PhecAdGroup_AdGroupId ON dbo.PhecAdGroup(AdGroupId)
GO
