CREATE PROCEDURE [dbo].[uspNotificationSummaryByRegion]
	(
			@NotificationYearFrom			INTEGER			=	-3,
			@NotificationMonthFrom			INTEGER			=	1,
			@NotificationYearTo				INTEGER			=	0,
			@NotificationMonthTo			INTEGER			=	1,
			@Region							VARCHAR(5000)	=	NULL,
			@GroupBy						VARCHAR(50)		=	'MONTH'

	)
AS
BEGIN TRY

	DECLARE @NotificationYearTypeFrom	VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
    DECLARE @NotificationDateFrom		DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)

    DECLARE @NotificationYearTypeTo		VARCHAR(16) = YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
    DECLARE @NotificationDateTo			DATE        = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
		SET @NotificationDateTo						= EOMONTH(@NotificationDateTo)

	DECLARE @DateFormat					VARCHAR(10)	= CASE @GroupBy WHEN 'MONTH' THEN 'yyyy-MM' ELSE 'yyyy' END;

	SELECT [Name] AS [Region] 
	INTO #RegionGroup
	FROM [$(NTBS)].ReferenceData.PHEC 
	UNION SELECT 'Unknown' AS Region

	-- Get the list of months
	SELECT [YearMonthValue], 
		MIN(FirstOfMonthValue) AS [FirstOfMonthValue]
	INTO #MonthNumber
	FROM Calendar
	WHERE [DateValue] >= @NotificationDateFrom AND [DateValue] <= @NotificationDateTo
	GROUP BY YearMonthValue

	-- Get list of years
	SELECT DISTINCT([YearValue])
	INTO #YearNumber
	FROM Calendar
	WHERE [DateValue] >= @NotificationDateFrom AND [DateValue] <= @NotificationDateTo

	-- Get Notification count by date period and region
	SELECT 
		COALESCE([TreatmentPhec], 'Unknown')		AS [Region], 
		FORMAT(rn.[NotificationDate], @DateFormat)	AS [DateGroup], 
		COUNT(rn.[NotificationId])					AS [NumberOfNotifications]
	INTO #Count
	FROM [dbo].ReusableNotification rn
	GROUP BY 
		FORMAT(rn.[NotificationDate], @DateFormat), 
		[TreatmentPhec]


	IF (@GroupBy = 'MONTH')
		SELECT m.[YearMonthValue]					AS 'Notification period sortable',
			FORMAT(m.[FirstOfMonthValue], 'MMM yyyy')	AS 'Notification period',
			r.[Region]								AS 'Region',		
			COALESCE (c.[NumberofNotifications], 0) AS 'Notification count'
		FROM #MonthNumber m 
			CROSS JOIN #RegionGroup r
			LEFT OUTER JOIN #Count AS c
			ON c.[Region] = r.[Region]
			AND c.[DateGroup] = m.[YearMonthValue]
		WHERE (@Region IS NULL OR r.Region IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')))
		ORDER BY
			r.[Region],
			m.[FirstOfMonthValue]
	ELSE IF (@GroupBy = 'YEAR')
		SELECT m.[YearValue]						AS 'Notification period sortable',
			m.[YearValue]							AS 'Notification period',
			r.[Region]								AS 'Region', 
			COALESCE (c.[NumberofNotifications], 0) AS 'Notification count'
		FROM #YearNumber m 
			CROSS JOIN #RegionGroup r
			LEFT OUTER JOIN #Count as c
			ON c.[Region] = r.[Region]
			AND c.[DateGroup] = m.[YearValue]
		WHERE (@Region IS NULL OR r.Region IN (SELECT VALUE FROM STRING_SPLIT(@Region, ',')))
		ORDER BY
			r.[Region],
			m.[YearValue]

	DROP TABLE #RegionGroup

	DROP TABLE #YearNumber

	DROP TABLE #MonthNumber

	DROP TABLE #Count
END TRY
BEGIN CATCH
END CATCH
GO