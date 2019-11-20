CREATE TABLE [dbo].[__MigrationLog](
	[SqlHash] [binary](64) NOT NULL,
	[StartTime] [datetime2](7) NOT NULL,
	[EndTime] [datetime2](7) NULL,
	[SqlText] [nvarchar](max) NOT NULL,
	[WasSuccessful] [bit] NOT NULL,
	[Error] [nvarchar](max) NULL,
	[Author] [nvarchar](250) NULL,
	[Build] [nvarchar](50) NULL,
 CONSTRAINT [PK_MigrationLog] PRIMARY KEY CLUSTERED 
(
	[SqlHash] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
ALTER TABLE [dbo].[__MigrationLog] ADD  DEFAULT ((0)) FOR [WasSuccessful]