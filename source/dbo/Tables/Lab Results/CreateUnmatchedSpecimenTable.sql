CREATE TABLE [labbase2].[dbo].[UnmatchedSpecimen]
(
	-- This primary key
	[Id] [int] IDENTITY(1,1) NOT NULL,
	-- specimen primary key
	[ReferenceLaboratoryNumber] [nvarchar](50) NOT NULL,
	[TB_Service_Code] [varchar](50) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL
	
	CONSTRAINT [PK_UnmatchedSpecimenId] PRIMARY KEY CLUSTERED (
		[Id] ASC
	)
) 

ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_UnmatchedSpecimen_ReferenceLaboratoryNumber ON dbo.LabSpecimen(ReferenceLaboratoryNumber)
GO

CREATE NONCLUSTERED INDEX IX_UnmatchedSpecimen_TB_Service_Code ON dbo.TB_Service(TB_Service_Code)
GO