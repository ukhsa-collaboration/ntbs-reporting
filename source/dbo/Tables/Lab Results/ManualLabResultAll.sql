CREATE TABLE [dbo].[ManualLabResultAll]
(
	[Id] [int] IDENTITY(1,1) NOT NULL,
	
	-- ETS primary key
	[EtsId] [bigint] NULL,

	--TestType
	[TestType] [nvarchar](30) NULL,

	--Result
	[Result] [nvarchar](9) NULL,



	CONSTRAINT [PK_ManualResultAllId] PRIMARY KEY CLUSTERED (
		[Id] ASC
	), 
    
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_ManualLabResultAll_EtsId ON dbo.ManualLabResult(EtsId)
GO
