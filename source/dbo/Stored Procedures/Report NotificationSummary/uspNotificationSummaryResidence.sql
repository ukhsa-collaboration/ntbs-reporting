/***************************************************************************************************
Desc:    This serves the "Notification Summary" notification aggregate counts for the residence
         portion of the report's entry web page.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspNotificationSummaryResidence]
	(
			@NotificationYearFrom			INTEGER			=	-3,
			@NotificationMonthFrom			INTEGER			=	1,
			@NotificationYearTo				INTEGER			=	0,
			@NotificationMonthTo			INTEGER			=	1,
			@Region							VARCHAR(50)		=	NULL,
			@GroupBy						VARCHAR(50)		=	'MONTH'

	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		-- START DEBUGGING
		--DECLARE @NotificationYearFrom INTEGER, @NotificationMonthFrom INTEGER, @NotificationYearTo INTEGER, @NotificationMonthTo INTEGER, @Region VARCHAR(50), @GroupBy VARCHAR(50)
		--SET @Region	= 'London'
		--SET @GroupBy = 'YEAR'
		--SET @NotificationYearFrom =	-3
		--SET @NotificationMonthFrom	= 1
		--SET @NotificationYearTo	= 0
		--SET @NotificationMonthTo = 1
		-- END DEBUGGING

		DECLARE @NotificationYearTypeFrom	VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
        DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)

        DECLARE @NotificationYearTypeTo		VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
        DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
		SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)
	
		IF (@GroupBy = 'MONTH')
			SELECT 
				FORMAT(n.NotificationDate, 'yyyy-MM')		AS 'Notification period sortable',
				FORMAT(n.NotificationDate, 'MMM yyyy')		AS 'Notification period',
				n.LocalAuthority							AS 'Local Authority',
				COUNT(n.NotificationId)						AS 'Notification count'
			FROM dbo.ReusableNotification n WITH (NOLOCK)
			WHERE 
					n.ResidencePhec = @Region
				AND n.NotificationDate BETWEEN @NotificationDateFrom and @NotificationDateTo
			GROUP BY 
				FORMAT(n.NotificationDate, 'yyyy-MM'),
				FORMAT(n.NotificationDate, 'MMM yyyy'),
				n.LocalAuthority
			ORDER BY 
				FORMAT(n.NotificationDate, 'yyyy-MM'),
				n.LocalAuthority
		ELSE IF (@GroupBy = 'YEAR')
			SELECT 
				FORMAT(n.NotificationDate, 'yyyy')			AS 'Notification period sortable',
				FORMAT(n.NotificationDate, 'yyyy')			AS 'Notification period',
				n.LocalAuthority							AS 'Local Authority',
				COUNT(n.NotificationId)						AS 'Notification count'
			FROM dbo.ReusableNotification n WITH (NOLOCK)
			WHERE 
					n.ResidencePhec = @Region
				AND n.NotificationDate BETWEEN @NotificationDateFrom and @NotificationDateTo
			GROUP BY 
				FORMAT(n.NotificationDate, 'yyyy'), 
				n.LocalAuthority
			ORDER BY 
				FORMAT(n.NotificationDate, 'yyyy'), 
				n.LocalAuthority
		ELSE 
			RAISERROR ('The @GroupBy argument passed is invalid', 16, 1) WITH NOWAIT
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
