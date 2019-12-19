/***************************************************************************************************
Desc:    This serves the "Notification Summary" notification aggregate counts for the treatment
         portion of the report's entry web page.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspNotificationSummaryTreatment]
	(
			@NotificationYearFrom			INTEGER			=	-3,
			@NotificationMonthFrom			INTEGER			=	1,
			@NotificationYearTo				INTEGER			=	0,
			@NotificationMonthTo			INTEGER			=	1,
			@Region							VARCHAR(50)		=	NULL,
			@GroupBy						VARCHAR(50)		=	'MONTH',
			@Service						Varchar(1000)	=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		-- START DEBUGGING
		-- DECLARE @NotificationYearFrom INTEGER, @NotificationMonthFrom INTEGER, @NotificationYearTo INTEGER, @NotificationMonthTo INTEGER, @Region VARCHAR(50), @GroupBy VARCHAR(50)
		-- SET @Region	= 'London'
		-- SET @GroupBy = 'MONTH'
		-- SET @NotificationYearFrom =	-3
		-- SET @NotificationMonthFrom	= 1
		-- SET @NotificationYearTo	= 0
		-- SET @NotificationMonthTo = 1
		-- END DEBUGGING

		DECLARE @NotificationYearTypeFrom	VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
        DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)

        DECLARE @NotificationYearTypeTo		VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
        DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
		SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)
					SET @Service = case when len(@Service) - len(replace(@Service, ',', '')) +1 = 
					(select count(*) from TB_Service where PhecName = @Region) then 'All' else @Service end
	
		If (@Service <> 'All')
		Begin
			IF (@GroupBy = 'MONTH')
				SELECT 
					FORMAT(n.NotificationDate, 'yyyy-MM')		AS 'Notification period sortable',
					FORMAT(n.NotificationDate, 'MMM yyyy')		AS 'Notification period',
					n.Service									AS 'TB Service',
					COUNT(n.NotificationId)						AS 'Notification count'
				FROM dbo.ReusableNotification n WITH (NOLOCK)
				inner join TB_Service s on s.TB_Service_Name = n.Service
				WHERE 
						n.TreatmentPhec = @Region
					AND n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					and Serviceid in (select value from STRING_SPLIT(@Service, ','))
					AND (@Region IS NULL OR n.TreatmentPhec = @Region)
				GROUP BY 
					FORMAT(n.NotificationDate, 'yyyy-MM'),
					FORMAT(n.NotificationDate, 'MMM yyyy'),
					n.Service
				ORDER BY 
					FORMAT(n.NotificationDate, 'yyyy-MM'),
					n.Service
			ELSE IF (@GroupBy = 'YEAR')
				SELECT 
					FORMAT(n.NotificationDate, 'yyyy')			AS 'Notification period sortable',
					FORMAT(n.NotificationDate, 'yyyy')			AS 'Notification period',
					n.Service									AS 'TB Service',
					COUNT(n.NotificationId)						AS 'Notification count'
				FROM dbo.ReusableNotification n WITH (NOLOCK)
				inner join TB_Service s on s.TB_Service_Name = n.Service
				WHERE 
						n.TreatmentPhec = @Region
					AND n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					and Serviceid in (select value from STRING_SPLIT(@Service, ','))
					AND (@Region IS NULL OR n.TreatmentPhec = @Region)
				GROUP BY 
					FORMAT(n.NotificationDate, 'yyyy'), 
					n.Service
				ORDER BY 
					FORMAT(n.NotificationDate, 'yyyy'), 
					n.Service
			ELSE 
				RAISERROR ('The @GroupBy argument passed is invalid', 16, 1) WITH NOWAIT
			END

		If (@Service = 'All')
		Begin
						IF (@GroupBy = 'MONTH')
				SELECT 
					FORMAT(n.NotificationDate, 'yyyy-MM')		AS 'Notification period sortable',
					FORMAT(n.NotificationDate, 'MMM yyyy')		AS 'Notification period',
					n.Service									AS 'TB Service',
					COUNT(n.NotificationId)						AS 'Notification count'
				FROM dbo.ReusableNotification n WITH (NOLOCK)
				WHERE 
					--	n.TreatmentPhec = @Region
					n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					AND (n.TreatmentPhec = @Region )
				GROUP BY 
					FORMAT(n.NotificationDate, 'yyyy-MM'),
					FORMAT(n.NotificationDate, 'MMM yyyy'),
					n.Service
				ORDER BY 
					FORMAT(n.NotificationDate, 'yyyy-MM'),
					n.Service
			ELSE IF (@GroupBy = 'YEAR')
				SELECT 
					FORMAT(n.NotificationDate, 'yyyy')			AS 'Notification period sortable',
					FORMAT(n.NotificationDate, 'yyyy')			AS 'Notification period',
					n.Service									AS 'TB Service',
					COUNT(n.NotificationId)						AS 'Notification count'
				FROM dbo.ReusableNotification n WITH (NOLOCK)
				WHERE 
					--	n.TreatmentPhec = @Region
					n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
					AND (n.TreatmentPhec = @Region )
				GROUP BY 
					FORMAT(n.NotificationDate, 'yyyy'), 
					n.Service
				ORDER BY 
					FORMAT(n.NotificationDate, 'yyyy'), 
					n.Service
			ELSE 
				RAISERROR ('The @GroupBy argument passed is invalid', 16, 1) WITH NOWAIT
		END

	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
