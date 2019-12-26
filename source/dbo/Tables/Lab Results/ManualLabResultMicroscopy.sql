CREATE TABLE [dbo].[ManualLabResultMicroscopy]
(
	[Id] [int] IDENTITY(1,1) NOT NULL,
	
	-- ETS primary key
	[EtsId] [bigint] NULL,

	--Microscopy Result
	[Result] [nvarchar](9) NULL,

	--Whether result is for sputum or non-sputum microscopy
	[Sputum] [tinyint]

	

	CONSTRAINT [PK_ManualResultMicroscopyId] PRIMARY KEY CLUSTERED (
		[Id] ASC
	), 
    
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_ManualLabResultMicroscopy_EtsId ON dbo.ManualLabResult(EtsId)
GO
