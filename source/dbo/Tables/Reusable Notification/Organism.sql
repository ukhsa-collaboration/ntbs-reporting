/***************************************************************************************************
Desc:    This contains the authorative organism/species name of the tuberculosis bacteria identified.


         
**************************************************************************************************/

CREATE TABLE [dbo].[Organism](
	[OrganismId] [tinyint] IDENTITY(1,1) NOT NULL,
	[Organism_CD] [varchar](50) NOT NULL,
	[OrganismName] [varchar](50) NOT NULL,
	[SortOrder] TINYINT NOT NULL

	CONSTRAINT [PK_OrganismName] PRIMARY KEY CLUSTERED (
		[OrganismId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_Organism_SortOrder ON dbo.Organism(SortOrder)
GO
