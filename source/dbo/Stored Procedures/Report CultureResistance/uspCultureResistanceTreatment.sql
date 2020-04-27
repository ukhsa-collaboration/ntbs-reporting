/***************************************************************************************************
Desc:    This serves the "Culture And Resistance Line List", which returns every/most notification data point
         in detail, based on the user's permission & filtering preference. Every notification record
		 returned gets audited, whch means a log entry gets added for each user that views a notification.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspCultureResistanceTreatment]
	(
		@NotificationYearFrom	INTEGER			=	-3,		-- The report's "Year"  drop-down from which notifications are being returned
		@NotificationMonthFrom	INTEGER			=	1,		-- The report's "Month" drop-down from which notifications are being returned
		@NotificationYearTo		INTEGER			=	0,		-- The report's "Year" drop-down up to which notifications are being returned
		@NotificationMonthTo	INTEGER			=	1,		-- The report's "Month" drop-down up to which notifications are being returned
	--	@ResidenceTreatment		TINYINT			=   3,		-- The report's "Residence or Treatment?" drop-down that controls whether notifications are within a certain PHEC rgion
		@Region					VARCHAR(50)		=	NULL,	-- The report's "Region" drop-down that allows to view notifications of others PHECs (based on permissions)
		@SiteOfDisease			VARCHAR(16)		=	NULL,	-- The report's "Site Of Disease" drop-down that filters on "Pulmonary, Extra-Pulmonary" notifications
		@Service				varchar(5000)	=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		IF (@LoginGroups != '###')
		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
            DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)
			SET @Service = case when len(@Service) - len(replace(@Service, ',', '')) +1 = 
					(select count(*) from TB_Service where PhecName = @Region) then 'All' else @Service end

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
			If (@Service <> 'All')
			Begin
				SELECT
					n.[Service]								AS 'Service',

					SUM(c.CulturePositiveCases)				AS 'Culture positive cases',
					dbo.ufnCalculatePercentage(
						SUM(c.CulturePositiveCases),
						SUM(c.CulturePositiveCases) + SUM(c.NonCulturePositiveCases)
					)										AS 'Culture positive percentage',

					SUM(c.NonCulturePositiveCases)          AS 'Non-culture positive cases',
					dbo.ufnCalculatePercentage(
						SUM(c.NonCulturePositiveCases),
						SUM(c.CulturePositiveCases) + SUM(c.NonCulturePositiveCases)
					)									AS 'Non-culture positive percentage',

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
					inner join TB_Service s on s.TB_Service_Name = n.Service
				WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					and Serviceid in (select value from STRING_SPLIT(@Service, ','))
					AND (n.SiteOfDisease = @SOD OR @SOD IS NULL)		
					AND n.TreatmentPhec IS NOT NULL -- Exclude non-english phecs
					AND n.ResidencePhec IS NOT NULL -- Exclude non-english phecs	
					AND (@Region IS NULL OR n.TreatmentPhec = @Region)
				GROUP BY n.[Service]
				ORDER BY n.[Service]
			END
			
			
			If (@Service = 'All')
			Begin
				SELECT
					n.[Service]								AS 'Service',

					SUM(c.CulturePositiveCases)				AS 'Culture positive cases',
					dbo.ufnCalculatePercentage(
						SUM(c.CulturePositiveCases),
						SUM(c.CulturePositiveCases) + SUM(c.NonCulturePositiveCases)
					)										AS 'Culture positive percentage',

					SUM(c.NonCulturePositiveCases)          AS 'Non-culture positive cases',
					dbo.ufnCalculatePercentage(
						SUM(c.NonCulturePositiveCases),
						SUM(c.CulturePositiveCases) + SUM(c.NonCulturePositiveCases)
					)									AS 'Non-culture positive percentage',

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
					AND (n.SiteOfDisease = @SOD OR @SOD IS NULL)		
					AND n.TreatmentPhec IS NOT NULL -- Exclude non-english phecs
					AND n.ResidencePhec IS NOT NULL -- Exclude non-english phecs	
					AND (@Region IS NULL OR n.TreatmentPhec = @Region)
				GROUP BY n.[Service]
				ORDER BY n.[Service]
			END
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH