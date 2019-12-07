/*CREATE TABLE [NTBS_Specimen_Matching].[dbo].[UnmatchedSpecimen]
(
	-- This primary key
	[Id] [int] IDENTITY(1,1) NOT NULL,
	-- specimen primary key
	[ReferenceLaboratoryNumber] [nvarchar](50) NOT NULL,
	[TB_Service_Code] [nvarchar](16) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL
	
	CONSTRAINT [PK_UnmatchedSpecimenId] PRIMARY KEY CLUSTERED (
		[Id] ASC
	)
) 

ON [PRIMARY]
GO

--TODO cannot create indexes due to lack of cross database functionality
--CREATE NONCLUSTERED INDEX IX_UnmatchedSpecimen_ReferenceLaboratoryNumber ON dbo.LabSpecimen(ReferenceLaboratoryNumber)
--GO

--CREATE NONCLUSTERED INDEX IX_UnmatchedSpecimen_TB_Service_Code ON dbo.TB_Service(TB_Service_Code)
--GO*/