USE [NTBS_Reporting_Staging]
GO
/****** Object:  StoredProcedure [dbo].[uspLabSpecimen]    Script Date: 30/11/2019 08:08:06 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[uspTemporaryLabSpecimen] AS
	SET NOCOUNT ON

	BEGIN TRY

		-- Reset
		DELETE FROM dbo.TemporaryLabSpecimen

		INSERT INTO [dbo].[TemporaryLabSpecimen] VALUES ('M.19.0999911.M', CAST(N'2019-11-12T00:00:00.000' AS DateTime),'Sputum', 'Royal Free Hospital Microbiology', 
			'NMRL', 'M. tuberculosis', NULL, CAST(N'1972-01-25T00:00:00.000' AS DateTime), 'POSTCODE, ANTHONY', N'F', NULL, N'LS167QQ', 
			12, 'Possible', CAST(N'2019-12-02T00:00:00.000' AS DateTime), CAST(N'2019-12-02T00:00:00.000' AS DateTime), 
			0.5, CAST(N'2019-11-04T00:00:00.000' AS DateTime), 'POSTCODE, TONY', '9988776655', CAST(N'1971-01-25T00:00:00.000' AS DateTime), 'LS16 7QQ', 1)

		INSERT INTO [dbo].[TemporaryLabSpecimen] VALUES ('M.19.0999911.M', CAST(N'2019-11-12T00:00:00.000' AS DateTime),'Sputum', 'Royal Free Hospital Microbiology', 
			'NMRL', 'M. tuberculosis', NULL, CAST(N'1972-01-25T00:00:00.000' AS DateTime), 'POSTCODE, ANTHONY', N'F', NULL, N'LS167QQ', 
			13, 'Possible', CAST(N'2019-12-02T00:00:00.000' AS DateTime), CAST(N'2019-12-02T00:00:00.000' AS DateTime), 
			0.45, CAST(N'2019-11-17T00:00:00.000' AS DateTime), 'POST-CODE, ANTONIA', '7766559988', CAST('1971-01-25T00:00:00.000' AS DateTime), 'LS16 7QQ', 2)

		INSERT INTO [dbo].[TemporaryLabSpecimen] VALUES ('H170280028', CAST(N'2019-11-14T00:00:00.000' AS DateTime),'Bronchoscopy sample', 'Luton Microbiology Laboratory', 
			'NMRL', 'M. tuberculosis', '45645611', CAST(N'1972-01-25T00:00:00.000' AS DateTime), 'CAMPBELL, COLIN', 'M', NULL, N'LS14BY', NULL, NULL, NULL, NULL,
			NULL, NULL, NULL, NULL, NULL, NULL, NULL)

	END TRY
	BEGIN CATCH
		THROW
	END CATCH


