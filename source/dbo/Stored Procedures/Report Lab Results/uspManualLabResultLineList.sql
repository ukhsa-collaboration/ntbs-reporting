CREATE PROCEDURE [dbo].[uspManualLabResultLineList]
		@NotificationYearFrom	INTEGER			=	-3,
		@NotificationMonthFrom	INTEGER			=	1,
		@NotificationYearTo		INTEGER			=	0,
		@NotificationMonthTo	INTEGER			=	1,
		@ResidenceTreatment		TINYINT			=   1,
		@Region					VARCHAR(50)		=	NULL
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN

			/*
				-- Debugging
				DECLARE @NotificationYearFrom INTEGER = -1
				DECLARE @NotificationMonthFrom INTEGER = 1
				DECLARE @NotificationYearTo INTEGER = -1

				DECLARE @NotificationMonthTo INTEGER = 3
				DECLARE @ResidenceTreatment INTEGER = 1
				
				DECLARE @Region VARCHAR(50) = 'London'
				
				DECLARE @LoginGroups VARCHAR(50) = '###Global.NIS.NTBS.LON###'
			*/
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
			DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
			DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
			DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo) -- Move end date to last day of month

			DECLARE @ReusableNotification ReusableNotificationType

			INSERT INTO @ReusableNotification
				SELECT n.*
				FROM dbo.ufnAuthorizedReusableNotification(@LoginGroups) n  -- This filters the records by regional PHEC permissions!
				WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					AND (
							(
									@ResidenceTreatment = 1 AND
									(n.TreatmentPhec = @Region OR n.ResidencePhec = @Region)
							) OR (
									@ResidenceTreatment = 2 AND
									n.TreatmentPhec = @Region
							) OR (
									@ResidenceTreatment = 3 AND
									n.ResidencePhec = @Region
							)
						)
			SELECT
				-- Primary key
				n.NotificationId                                       AS 'ID',

				-- Demographics
				n.EtsId                                                AS 'ETS ID',
				n.LtbrId                                               AS 'LTBR ID',
				dbo.ufnFormatDateConsistently(n.NotificationDate)      AS 'Notification date',
				n.[Service]                                            AS 'Service',
				mr.Microscopy										   AS 'Microscopy',
				mr.MicroscopySputum									   AS 'Microscopy sputum',
				mr.MicroscopyNonSputum								   AS 'Microscopy non-sputum',
				mr.Histology										   AS 'Histology',
				mr.Amplification									   AS 'Molecular Amplification',
				mr.Culture											   AS 'Manually-entered culture'	
				
			FROM @ReusableNotification n
				INNER JOIN dbo.ManualLabResult mr ON mr.EtsId = n.EtsId
			ORDER BY n.NotificationDate DESC

			-- Write data to audit log
			EXEC dbo.uspAddToAudit 'Manual Lab Result Line List', @LoginGroups, @ReusableNotification
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
RETURN 0
