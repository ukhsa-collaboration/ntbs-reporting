/***************************************************************************************************
Desc:    This is a placeholder for ETS postcode reference data to reside in, as it has to be modified,
         so that ReusableNotification.ResidencePhec and ReusableNotification.LocalAuthoraty can be 
		 calculated over-night.


         
**************************************************************************************************/

CREATE TABLE [dbo].[PostcodeLookup](
	[PostcodeLookupId] [uniqueidentifier] NOT NULL,
	[Pcd2] [nvarchar](20) NULL,
	[Pcd2NoSpaces] [nvarchar](20) NULL

	 CONSTRAINT [PK_PostcodeLookup] PRIMARY KEY CLUSTERED (
		[PostcodeLookupId] ASC
	)
)
GO

CREATE NONCLUSTERED INDEX IX_PostcodeLookup_Pcd2 ON dbo.PostcodeLookup(Pcd2)
GO
CREATE NONCLUSTERED INDEX IX_PostcodeLookup_Pcd2NoSpaces ON dbo.PostcodeLookup(Pcd2NoSpaces)
GO
