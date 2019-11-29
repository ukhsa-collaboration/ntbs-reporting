USE [NTBS_Reporting_Staging]
GO

/****** Object:  StoredProcedure [dbo].[uspLabSpecimen]    Script Date: 29/11/2019 14:19:00 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[uspLabSpecimen] AS
	SET NOCOUNT ON

	BEGIN TRY
		
		-- Reset
		DELETE FROM dbo.LabSpecimen

		INSERT INTO dbo.LabSpecimen
			 
			/*this brings back info about each specimen - date, type, requesting lab, ref lab, species and patient info - for notifications in January 2019*/
			SELECT DISTINCT
				CASE
					WHEN sr.ReferenceLaboratoryNumber is not null THEN TRIM(sr.ReferenceLaboratoryNumber)
					ELSE CONCAT('TBSURV', a.IdentityColumn)
				END AS 'ReferenceLaboratoryNumber'
				--TODO: SPECIMEN DATE MAY BE DIFFERENT BETWEEN ENTRIES FOR THE SAME SPECIMEN
				,sr.SpecimenDate
				--SPECIMEN TYPE CODE AND LAB NAME MAY BE DIFFERENT BETWEEN ENTRIES FOR THE SAME SPECIMEN
				,NULL
				,NULL
				,TRIM(a.ReferenceLaboratory) AS 'ReferenceLaboratory'
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
				,NULL
			FROM [labbase2].[dbo].[SpecimenResult] sr
				LEFT OUTER JOIN [labbase2].[dbo].[Anonymised] a ON sr.LabDataID = a.LabDataID
				--TODO Temp fix to bring back less data during dev
				WHERE sr.SpecimenDate > '2019-01-25'
			ORDER BY ReferenceLaboratoryNumber

		-- now go through and add in specimen type

		
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
GO

