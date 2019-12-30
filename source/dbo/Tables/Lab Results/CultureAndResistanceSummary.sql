CREATE TABLE [dbo].[CultureAndResistanceSummary](
	[CARSummaryId] [int] IDENTITY(1,1) NOT NULL,
	[NotificationId] INT NOT NULL, 
	[CulturePositive] [nvarchar](3) NULL,
	[Species] [varchar](50) NULL,
	[DrugResistanceProfile] [nvarchar](30) NULL,
	[EarliestSpecimenDate] [datetime] NULL,
	[INH][nvarchar](25) NULL,
	[RIF][nvarchar](25) NULL,
	[PYR][nvarchar](25) NULL,
	[ETHAM][nvarchar](25) NULL,
	[MDR][nvarchar](10) NULL,
	[AMINO][nvarchar](25) NULL,
	[QUIN][nvarchar](25) NULL,
	[XDR][nvarchar](10) NULL,
	
 CONSTRAINT [PK_CARSummaryId] PRIMARY KEY CLUSTERED 
(
	[CARSummaryId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
