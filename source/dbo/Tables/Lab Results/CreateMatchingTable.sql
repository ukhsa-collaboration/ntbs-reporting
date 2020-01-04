CREATE TABLE [$(NTBS_Specimen_Matching)].[dbo].[NotificationSpecimenMatch]
(
	-- This primary key
	[MatchId] [int] IDENTITY(1,1) NOT NULL,
	-- specimen primary key
	[ReferenceLaboratoryNumber] [nvarchar](50) NOT NULL,
	[NotificationID] int NOT NULL,
	[MatchType] [nvarchar](30) NOT NULL,
	[CreateDateTime] [datetime] NULL,
	[UpdateDateTime] [datetime] NULL,
	[ConfidenceLevel] [decimal](5,2) NULL
	
	CONSTRAINT [PK_LabSpecimenId] PRIMARY KEY CLUSTERED (
		[MatchId] ASC
	)
) 

ON [PRIMARY]
GO


CREATE NONCLUSTERED INDEX IX_NotificationSpecimenMatch_ReferenceLaboratoryNumber ON  dbo.LabSpecimen(ReferenceLaboratoryNumber)
--GO

*/