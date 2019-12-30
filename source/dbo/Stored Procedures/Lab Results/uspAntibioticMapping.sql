CREATE PROCEDURE [dbo].[uspAntibioticMapping]
	
AS

	SET NOCOUNT ON

	BEGIN TRY
		--RESET
		DELETE FROM [dbo].[AntibioticMapping]
		--REPOPULATE
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'ETA_W', 1, N'ETHAM')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'ETHAM', 0, N'ETHAM')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'ETHAM_W', 1, N'ETHAM')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'ISO', 0, N'INH')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'ISO_W', 1, N'INH')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'RIF', 0, N'RIF')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'RIF_W', 1, N'RIF')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'PYR', 0, N'PYR')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'PYR_W', 1, N'PYR')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'CLA', 0, N'CLA')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'AK', 0, N'AK')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'AMI', 0, N'AMI')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'AMINO_W', 1, N'AMINO')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'AZI', 0, N'AZI')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'CAP', 0, N'CAP')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'CIP', 0, N'CIP')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'CLOF', 0, N'CLOF')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'CYC', 0, N'CYC')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'ETHION', 0, N'ETHION')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'IMI', 0, N'IMI')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'KAN', 0, N'KAN')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'LEV', 0, N'LEV')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'LINZ', 0, N'LINZ')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'LZD', 0, N'LZD')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'MOXI', 0, N'MOXI')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'OFL', 0, N'OFL')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'OFX', 0, N'OFX')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'PAS', 0, N'PAS')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'PRO', 0, N'PRO')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'QUIN_W', 1, N'QUIN')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'LZD', 0, N'LZD')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'RIFB', 0, N'RIFB')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'STR', 0, N'STR')
		INSERT [dbo].[AntibioticMapping] ([AntibioticCode], [IsWGS], [AntibioticOutputName]) VALUES (N'STR_W', 0, N'STR')
	END TRY
	BEGIN CATCH
		THROW
	END CATCH