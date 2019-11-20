/***************************************************************************************************
Desc:    This re/calculates the value for the data points ReusableNotification.ISO,
         ReusableNotification.RIF, ReusableNotification.ETHAM, and ReusableNotification.PYR
         for each notification record (every night when the uspGenerate schedule runs).
		 The inline comments no 1, 2, 3 ... below have been copied across from the NTBS R1
		 specification in Confluence, and are to be kept in sync with that specification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspGenerateReusableNotificationCultureResistance] (
	@ReportingAntibioticCode NVARCHAR(5) = '',
	@EtsAntibioticCodeList NVARCHAR(100) = ''
) AS
	BEGIN TRY
		SET NOCOUNT ON

		-- Debugging
		-- DECLARE @EtsAntibioticCodeList VARCHAR(5) = 'INH'
		-- DECLARE @ReportingAntibioticCode VARCHAR(5) = 'ISO'

		DECLARE @Sql NVARCHAR(2000)

		-- 1. Patient has no drug sensitivity test results for the given antibiotic
		SET @Sql = 'UPDATE dbo.ReusableNotification SET
						' + @ReportingAntibioticCode + ' = ''No result''
					WHERE ' + @ReportingAntibioticCode + ' IS NULL
						AND NotificationId NOT IN (SELECT DISTINCT l.NotificationId
													FROM [$(ETS)].dbo.LaboratoryResult l
														INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.OpieId = l.OpieId
													WHERE a.LabDataID IN (SELECT DISTINCT su.LabDataID
																			FROM [$(Labbase2)].dbo.Susceptibility su
																			WHERE su.AntibioticCode IN (' + @EtsAntibioticCodeList + ')))' -- Comma-separated list of codes

		PRINT @Sql
		EXEC sp_executesql @Sql

		-- 2. Patient has one or more drug sensitivity test results for the given antibiotic with the value 'Resistant' or 'R'
		SET @Sql = 'UPDATE dbo.ReusableNotification SET
						' + @ReportingAntibioticCode + ' = ''Resistant''
					WHERE ' + @ReportingAntibioticCode + ' IS NULL
						AND NotificationId IN (SELECT DISTINCT l.NotificationId
													FROM [$(ETS)].dbo.LaboratoryResult l
														INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.OpieId = l.OpieId
													WHERE a.LabDataID IN (SELECT DISTINCT su.LabDataID
																			FROM [$(Labbase2)].dbo.Susceptibility su
																			WHERE su.AntibioticCode IN (' + @EtsAntibioticCodeList + ') -- Comma-separated list of codes
																			AND su.SusceptibilityResult IN (''Resistant'', ''R'')))'

		PRINT @Sql
		EXEC sp_executesql @Sql

		-- 3. Patient has one or more drug sensitivity test results for the given antibiotic with the value 'Sensitive' or 'S'
		SET @Sql = 'UPDATE dbo.ReusableNotification SET
						' + @ReportingAntibioticCode + ' = ''Sensitive''
					WHERE ' + @ReportingAntibioticCode + ' IS NULL
					AND NotificationId IN (SELECT DISTINCT l.NotificationId
												FROM [$(ETS)].dbo.LaboratoryResult l
													INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.OpieId = l.OpieId
												WHERE a.LabDataID IN (SELECT DISTINCT su.LabDataID
																		FROM [$(Labbase2)].dbo.Susceptibility su
																		WHERE su.AntibioticCode IN (' + @EtsAntibioticCodeList + ') -- Comma-separated list of codes
																		AND su.SusceptibilityResult IN (''Sensitive'', ''S'')))'

		PRINT @Sql
		EXEC sp_executesql @Sql

		-- 4. Patient ONLY has drug sensitivity test results which are 'Unknown' or 'Failed'
		-- The SQL where clause below "looks" duplicated, but watch out for the 2 "NOT IN" differences
		SET @Sql = 'UPDATE dbo.ReusableNotification SET
						' + @ReportingAntibioticCode + ' = ''Unknown''
					WHERE ' + @ReportingAntibioticCode + ' IS NULL
					AND NotificationId IN (SELECT DISTINCT l.NotificationId
											FROM [$(ETS)].dbo.LaboratoryResult l
												INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.OpieId = l.OpieId
											WHERE a.LabDataID IN (SELECT DISTINCT su.LabDataID
																	FROM [$(Labbase2)].dbo.Susceptibility su
																	WHERE su.AntibioticCode IN (' + @EtsAntibioticCodeList + ') -- Comma-separated list of codes
																	AND su.SusceptibilityResult IN (''Unknown'', ''U'', ''Failed'', ''F'')))
					AND NotificationId NOT IN (SELECT DISTINCT l.NotificationId
												FROM [$(ETS)].dbo.LaboratoryResult l
													INNER JOIN [$(Labbase2)].dbo.Anonymised a ON a.OpieId = l.OpieId
												WHERE a.LabDataID IN (SELECT DISTINCT su.LabDataID
																		FROM [$(Labbase2)].dbo.Susceptibility su
																		WHERE su.AntibioticCode IN (' + @EtsAntibioticCodeList + ') -- Comma-separated list of codes
																		AND su.SusceptibilityResult NOT IN (''Unknown'', ''U'', ''Failed'', ''F'')))'


		PRINT @Sql
		EXEC sp_executesql @Sql

		-- 5. An error has occurred
		SET @Sql = 'UPDATE dbo.ReusableNotification SET
						' + @ReportingAntibioticCode + ' = ''Error: Invalid value''
					WHERE ' + @ReportingAntibioticCode + ' IS NULL'

		PRINT @Sql
		EXEC sp_executesql @Sql
	END TRY
	BEGIN CATCH
		THROW
	END CATCH
