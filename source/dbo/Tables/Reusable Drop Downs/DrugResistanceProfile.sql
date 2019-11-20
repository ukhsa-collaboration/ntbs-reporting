/***************************************************************************************************
Desc:    This contains the DrugResistanceProfile drop-down values.


         
**************************************************************************************************/

CREATE TABLE [dbo].[DrugResistanceProfile] (
	[DrugResistanceProfileId] [tinyint] IDENTITY(1,1) NOT NULL,
	[ResistantId] [tinyint] NOT NULL,
	[DrugResistanceProfile] [varchar](50) NOT NULL

	CONSTRAINT [PK_DrugResistanceProfile] PRIMARY KEY CLUSTERED (
		[DrugResistanceProfileId] ASC
	)
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[DrugResistanceProfile]  WITH CHECK ADD CONSTRAINT [FK_DrugResistanceProfile_Resistant] FOREIGN KEY([ResistantId]) REFERENCES [dbo].[Resistant] ([ResistantId]) ON UPDATE CASCADE ON DELETE NO ACTION;
GO
