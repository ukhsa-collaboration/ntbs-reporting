/***************************************************************************************************
Desc:    This contains the non-authorative organism/species name of the tuberculosis bacteria identified.
         This non-authorative organism name is how the organism is stored in ETS, but not how the 
		 reporting environment is to display it.


         
**************************************************************************************************/

CREATE TABLE [dbo].[OrganismNameMapping](
	[OrganismNameMappingId] [smallint] IDENTITY(1,1) NOT NULL,
	[OrganismName] [varchar](100) NOT NULL,
	[OrganismId] [tinyint] NOT NULL

	 CONSTRAINT [PK_OrganismNameMapping] PRIMARY KEY CLUSTERED (
		[OrganismNameMappingId] ASC
	)
) ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_Organism_OrganismId ON dbo.Organism(OrganismId)
GO

ALTER TABLE [dbo].[OrganismNameMapping]  WITH CHECK ADD CONSTRAINT [FK_OrganismNameMapping_Organism] FOREIGN KEY([OrganismID]) REFERENCES [dbo].[Organism] ([OrganismId]) ON UPDATE CASCADE ON DELETE CASCADE;
GO
