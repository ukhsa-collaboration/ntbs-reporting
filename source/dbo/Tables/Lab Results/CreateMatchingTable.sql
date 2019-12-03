CREATE TABLE [NTBS_Specimen_Matching].[dbo].[NotificationSpecimenMatch]
(
	-- This primary key
	[MatchId] [int] IDENTITY(1,1) NOT NULL,
	-- specimen primary key
	[ReferenceLaboratoryNumber] [nvarchar](50) NOT NULL,
	[NotificationID] int NOT NULL,
	[MatchType] [nvarchar](30) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[ConfidenceLevel] [decimal](3,2) NULL
	
	CONSTRAINT [PK_LabSpecimenId] PRIMARY KEY CLUSTERED (
		[MatchId] ASC
	)
) 

ON [PRIMARY]
GO

--TODO cannot create index because of lack of cross database functionality
--CREATE NONCLUSTERED INDEX IX_NotificationSpecimenMatch_ReferenceLaboratoryNumber ON [NTBS_Reporting_Staging].dbo.LabSpecimen(ReferenceLaboratoryNumber)
--GO