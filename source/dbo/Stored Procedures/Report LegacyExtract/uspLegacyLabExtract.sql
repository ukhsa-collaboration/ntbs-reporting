/***************************************************************************************************
Desc:    This serves the "Enhanced Line List", which returns every/most notification data point
         in detail, based on the user's permission & filtering preference. Every notification record
		 returned gets audited, whch means a log entry gets added for each user that views a notification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspLegacyLabExtract]
	(
		@NotificationYearFrom	INTEGER			=	-3,
		@NotificationMonthFrom	INTEGER			=	1,
		@NotificationYearTo		INTEGER			=	0,
		@NotificationMonthTo	INTEGER			=	1,
		@Region					VARCHAR(1000)	=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		--don't think I need this bit
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT
		--as this check is done in uspPhec/uspService
		-- Debugging
		-- EXEC master..xp_logevent 60000, @LoginGroups

		DECLARE @allowedRegions TABLE(PhecCode VARCHAR(20), PhecName VARCHAR(50), SortOrder INT)
		INSERT @allowedRegions
			EXEC [dbo].[uspPhec] ''

		IF @Region IN (SELECT PhecName FROM @allowedRegions)

		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
			DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
			DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
			DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo) -- Move end date to last day of month

			--find list of services the user can query in the given region. For regional/national staff, it will be all
			--for service users, just their own services
			DECLARE @allowedServices TABLE(ServiceId INT, TB_Service_Name VARCHAR(150))
				INSERT @allowedServices
					EXEC [dbo].[uspService] @Region
			

			

			DECLARE @ReusableNotification ReusableNotificationType

			INSERT INTO @ReusableNotification (NotificationId)
				SELECT
					NotificationId
				FROM [dbo].[LegacyExtract] le
				WHERE
					le.CaseReportDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					AND (Region = @Region OR TreatmentRegion = @Region)
					AND TbService IN 
						(SELECT TB_Service_Name FROM @allowedServices)
				


			-- Return data to client app
			SELECT
				le.[NtbsId]													AS 'NtbsId'
				,le.[EtsId]													AS 'Id'
				,le.[IDOriginal]											AS 'IDOriginal'
				,lbe.[Source]												AS 'Source'
				,lbe.LaboratoryTestType										AS 'LaboratoryTestType'
				,lbe.Specimen												AS 'Specimen'
				,FORMAT(lbe.SpecimenDate, 'dd/MM/yyyy')						AS 'SpecimenDate'
				,lbe.Result													AS 'Result'
				,lbe.Species												AS 'Species'
				,lbe.SourceLabName											AS 'SourceLabName'
				,lbe.PatientId												AS 'PatientId'
				,lbe.OpieID													AS 'MycobNetID'
				,lbe.Isoniazid												AS 'Isoniazid'
				,lbe.Rifampicin												AS 'Rifampicin'
				,lbe.Ethambutol												AS 'Ethambutol'
				,lbe.Pyrazinamide											AS 'Pyrazinamide'
				,lbe.Streptomycin											AS 'Streptomycin'
				,lbe.Amikacin												AS 'Amikacin'
				,lbe.Azithromycin											AS 'Azithromycin'
				,lbe.Capreomycin											AS 'Capreomycin'
				,lbe.Ciprofloxacin											AS 'Ciprofloxacin'
				,lbe.Clarithromycin											AS 'Clarithromycin'
				,lbe.Clofazimine											AS 'Clofazimine'
				,lbe.Cycloserine											AS 'Cycloserine'
				,lbe.Ethionamide											AS 'Ethionamide'
				,lbe.PAS													AS 'PAS'
				,lbe.Prothionamide											AS 'Prothionamide'
				,lbe.Rifabutin												AS 'Rifabutin'
				,lbe.Moxifloxacin											AS 'Moxifloxacin'
				,lbe.Ofloxacin												AS 'Ofloxacin'
				,lbe.Kanamycin												AS 'Kanamycin'
				,lbe.Linezolid												AS 'Linezolid'
				,le.Denotified												AS 'Denotified'
				,lbe.ReferenceLaboratory									AS 'ReferenceLaboratory'
				,lbe.ReferenceLaboratoryNumber								AS 'ReferenceLaboratoryNumber'
				,lbe.SourceLaboratoryNumber									AS 'SourceLaboratoryNumber'
				,lbe.StrainType												AS 'StrainType'
				,lbe.Comments												AS 'Comments'
				--typo in 'Treatement' is required for backwards compatibility unfortunately
				,le.TreatmentRegion											AS 'TreatementRegion'
				,le.TreatmentHPU											AS 'TreatementHPU'
				,le.HospitalName											AS 'HospitalName'
				,le.HospitalPCT												AS 'HospitalPCT'
				,le.HospitalLocalAuthority									AS 'HospitalLocalAuthority'
				,le.ResolvedResidenceHPU
				,le.ResolvedResidenceRegion
				,le.ResolvedResidenceLA
				,le.NoFixedAbode
				,lbe.MatchType


			FROM [dbo].[LegacyExtract] le
				INNER JOIN [dbo].[LegacyLabExtract] lbe ON lbe.NotificationId = le.NotificationId AND le.SourceSystem = lbe.SourceSystem
				INNER JOIN @ReusableNotification n ON n.NotificationId = COALESCE(le.NtbsId, le.EtsId)
			ORDER BY le.CaseReportDate, lbe.SpecimenDate


			EXEC dbo.uspAddToAudit 'ETS Legacy Lab Extract', @LoginGroups, @ReusableNotification
		END
	ELSE
		BEGIN
			DECLARE @ErrorText NVARCHAR(50) = 'User not authorized to view data ' + @Region
			RAISERROR (@ErrorText, 16, 1) WITH NOWAIT
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
GO