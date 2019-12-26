CREATE TABLE [dbo].[ManualLabResult]
(
	[Id] [int] IDENTITY(1,1) NOT NULL,
	
	-- ETS primary key
	[EtsId] [bigint] NULL,

	--Microscopy Result
	[Microscopy] [nvarchar](9) NULL,

	--Microscopy Result for Sputum
	[MicroscopySputum] [nvarchar](9) NULL,

	--Microscopy Result for non-Sputum Samples
	[MicroscopyNonSputum] [nvarchar](9) NULL,

	--Histology
	[Histology] [nvarchar](9) NULL,

	--3	Mycobacterial Culture
	[Culture] [nvarchar](9) NULL,

	--4	Molecular Amplification
	[Amplification] [nvarchar](9) NULL,

	CONSTRAINT [PK_ManualResultId] PRIMARY KEY CLUSTERED (
		[Id] ASC
	), 
    
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX IX_ManualLabResult_EtsId ON dbo.ManualLabResult(EtsId)
GO
