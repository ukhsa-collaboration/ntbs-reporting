CREATE TABLE [NTBS_Reporting_Staging].[dbo].[SampleMapping]
(
	-- This primary key
	[SampleId] [int] IDENTITY(1,1) NOT NULL,
	[SampleName] [nvarchar](50) NOT NULL,
	[SampleRank] [int]

	CONSTRAINT [PK_SampleId] PRIMARY KEY CLUSTERED (
		[SampleId] ASC
	)
) 

ON [PRIMARY]
GO

CREATE NONCLUSTERED INDEX IX_SampleMapping_SampleName ON dbo.SampleMapping(SampleName)
GO