CREATE PROCEDURE [dbo].[uspCultureResistanceNational]
(
		@NotificationYearFrom	INTEGER			=	-3,
		@NotificationMonthFrom	INTEGER			=	1,
		@NotificationYearTo		INTEGER			=	0,
		@NotificationMonthTo	INTEGER			=	1,
		@SiteOfDisease			VARCHAR(16)		=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroupsAndType @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
            DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)

			DECLARE @SOD						VARCHAR(16) = (CASE WHEN @SiteOfDisease = 'All' THEN NULL ELSE @SiteOfDisease END)

			-- Debugging
			-- EXEC master..xp_logevent 60000, @SOD
		
			/*
				DECLARE @LoginGroups VARCHAR(500) = '###Global.NIS.NTBS.NTS###'
				DECLARE @NotificationDateFrom DATE = '2016-01-01'
				DECLARE @NotificationDateTo DATE = '2019-01-31'
				DECLARE @ResidenceTreatment TINYINT = 1
				DECLARE @SOD VARCHAR(16) = NULL
				DECLARE @Region VARCHAR(50) = 'London'
			*/

			SELECT
				n.TreatmentPhec							AS 'Region',

				SUM(c.CulturePositiveCases)				AS 'Culture positive cases',
				CAST(
					(100 / 
						(
							CAST(SUM(c.CulturePositiveCases) AS FLOAT) + 
							CAST(SUM(c.NonCulturePositiveCases) AS FLOAT)
						) * CAST(SUM(c.CulturePositiveCases) AS FLOAT)
					) AS DECIMAL(4, 1)
				)										AS 'Culture positive percentage',
				SUM(c.NonCulturePositiveCases)          AS 'Non-culture positive cases',
				CAST(
					(100 / 
						(
							CAST(SUM(c.NonCulturePositiveCases) AS FLOAT) + 
							CAST(SUM(c.CulturePositiveCases) AS FLOAT)
						) * CAST(SUM(c.NonCulturePositiveCases) AS FLOAT)
					) AS DECIMAL(4, 1)
				)										AS 'Non-culture positive percentage',
				SUM(c.CulturePositiveCases) +              
				SUM(c.NonCulturePositiveCases)			AS 'Table 1 total',

				SUM(c.SensitiveToAll4FirstLineDrugs)    AS 'Sensitive to all 4 first line drugs',
				dbo.ufnCalculatePercentage(
					SUM(c.SensitiveToAll4FirstLineDrugs),
					SUM(c.SensitiveToAll4FirstLineDrugs) + SUM(c.InhRes) + SUM(c.Other) + SUM(c.MdrRr) + SUM(c.Xdr) + SUM(c.IncompleteDrugResistanceProfile)
				)										AS 'Sensitive to all 4 first line drugs percentage',
				
				SUM(c.InhRes)                           AS 'INH-RES',
				dbo.ufnCalculatePercentage(
					SUM(c.InhRes),
					SUM(c.SensitiveToAll4FirstLineDrugs) + SUM(c.InhRes) + SUM(c.Other) + SUM(c.MdrRr) + SUM(c.Xdr) + SUM(c.IncompleteDrugResistanceProfile)
				)										AS 'INH-RES percentage',

				SUM(c.Other)                            AS 'Other',
				dbo.ufnCalculatePercentage(
					SUM(c.Other),
					SUM(c.SensitiveToAll4FirstLineDrugs) + SUM(c.InhRes) + SUM(c.Other) + SUM(c.MdrRr) + SUM(c.Xdr) + SUM(c.IncompleteDrugResistanceProfile)
				)										AS 'Other percentage',

				SUM(c.MdrRr)                            AS 'MDR/RR-TB',
				dbo.ufnCalculatePercentage(
					SUM(c.MdrRr),
					SUM(c.SensitiveToAll4FirstLineDrugs) + SUM(c.InhRes) + SUM(c.Other) + SUM(c.MdrRr) + SUM(c.Xdr) + SUM(c.IncompleteDrugResistanceProfile)
				)										AS 'MDR/RR-TB percentage',

				SUM(c.Xdr)                              AS 'XDR',
				dbo.ufnCalculatePercentage(
					SUM(c.Xdr),
					SUM(c.SensitiveToAll4FirstLineDrugs) + SUM(c.InhRes) + SUM(c.Other) + SUM(c.MdrRr) + SUM(c.Xdr) + SUM(c.IncompleteDrugResistanceProfile)
				)										AS 'XDR percentage',

				SUM(c.IncompleteDrugResistanceProfile)  AS 'Incomplete drug resistance profile',
				dbo.ufnCalculatePercentage(
					SUM(c.IncompleteDrugResistanceProfile),
					SUM(c.SensitiveToAll4FirstLineDrugs) + SUM(c.InhRes) + SUM(c.Other) + SUM(c.MdrRr) + SUM(c.Xdr) + SUM(c.IncompleteDrugResistanceProfile)
				)										AS 'Incomplete drug resistance profile percentage',

				SUM(c.SensitiveToAll4FirstLineDrugs) +
				SUM(c.InhRes) +
				SUM(c.Other) +
				SUM(c.MdrRr) +
				SUM(c.Xdr) +
				SUM(c.IncompleteDrugResistanceProfile)  AS 'Table 2 total'
			FROM dbo.ReusableNotification n WITH (NOLOCK)
				INNER JOIN dbo.CultureResistance c ON c.NotificationId = n.NotificationId
			WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
				AND n.TreatmentPhec IS NOT NULL -- Exclude non-english phecs
				AND n.ResidencePhec IS NOT NULL -- Exclude non-english phecs		
				AND (n.SiteOfDisease = @SOD OR @SOD IS NULL)			
			GROUP BY n.TreatmentPhec
			ORDER BY n.TreatmentPhec
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH