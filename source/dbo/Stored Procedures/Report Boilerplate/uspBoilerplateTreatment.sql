/***************************************************************************************************
Desc:    This serves the "Boilerplate" notification aggregate counts for the treatment
         portion of the report's entry web page.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspBoilerplateTreatment]
	(
		@NotificationYearFrom			INTEGER			=	-3,
		@NotificationMonthFrom			INTEGER			=	1,
		@NotificationYearTo				INTEGER			=	0,
		@NotificationMonthTo			INTEGER			=	1,
		@Region							VARCHAR(50)		=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		-- Debugging
		-- EXEC master..xp_logevent 60000, @Region

		IF (@LoginGroups != '###')
		BEGIN
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		VARCHAR(10) = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
            DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			VARCHAR(10) = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)

			SELECT
				n.[Service]								AS 'Service',
				SUM(b.BoilerplateCalculationNo1)		AS 'Boilerplate calculation no 1',
				SUM(b.BoilerplateCalculationNo2)		AS 'Boilerplate calculation no 2'
			FROM dbo.ReusableNotification n WITH (NOLOCK)
				INNER JOIN dbo.Boilerplate b ON b.NotificationId = n.NotificationId
			WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
				AND n.TreatmentPhec = @Region
			GROUP BY n.[Service]
			ORDER BY n.[Service]
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
