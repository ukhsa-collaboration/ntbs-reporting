/***************************************************************************************************
Desc:    This serves the "Data Quality" notification aggregate counts.


         
**************************************************************************************************/

CREATE PROCEDURE [dbo].[uspDataQuality]
	(
		@NotificationYearFrom			INTEGER			=	-3,
		@NotificationMonthFrom			INTEGER			=	1,
		@NotificationYearTo				INTEGER			=	0,
		@NotificationMonthTo			INTEGER			=	1,
		@Region							VARCHAR(50)		=	NULL,
		@ServiceName					VARCHAR(1000)	=	NULL
	)
AS
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE	@LoginGroups VARCHAR(500)
		EXEC dbo.uspGetAuthenticatedLoginGroups @LoginGroups OUTPUT

		--Debugging
		--EXEC master..xp_logevent 60000, @Region

		IF (@LoginGroups != '###')
		BEGIN
			--Date
			DECLARE @NotificationYearTypeFrom	VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearFrom, GETDATE()))
            DECLARE @NotificationDateFrom		VARCHAR(10) = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthFrom) + '/01/' + @NotificationYearTypeFrom)
            DECLARE @NotificationYearTypeTo		VARCHAR(4)	= YEAR(DATEADD(YEAR, @NotificationYearTo, GETDATE()))
            DECLARE @NotificationDateTo			VARCHAR(10) = CONVERT(DATE, CONVERT(VARCHAR(2), @NotificationMonthTo) + '/01/' + @NotificationYearTypeTo)
			SET @NotificationDateTo							= EOMONTH(@NotificationDateTo)
			SET @ServiceName = case when len(@ServiceName) - len(replace(@ServiceName, ',', '')) +1 = 
					(select count(*) from TB_Service where PhecName = @Region) then 'All' else @ServiceName end
			If (@ServiceName <> 'All')
			Begin
			SELECT 
				n.[Service]								AS 'Service',
				SUM(d.TreatmentEndDate)					AS 'Treatment end date',
				SUM(d.TreatmentOutcome12Months)			AS '12 month treatment outcome',
				SUM(d.TreatmentOutcome24Months)			AS '24 month treatment outcome',
				SUM(d.TreatmentOutcome36Months)			AS '36 month treatment outcome',
				SUM(d.DateOfDeath)						AS 'Date of death',
				SUM(d.DateOfBirth)						AS 'Date of birth',
				SUM(d.UKBorn)							AS 'UK born',
				SUM(d.SiteOfDisease)					AS 'Site of Disease',
				SUM(d.Denotify)							AS 'Denotify',
				SUM(d.OnsetToPresentationDays)					AS 'Onset to presentation days',
				SUM(d.PresentationToDiagnosisDays)					AS 'Presentation to diagnosis days',
				SUM(d.DiagnosisToTreatmentDays)					AS 'Diagnosis to treatment days',
				SUM(d.OnsetToTreatmentDays)					AS 'Onset to treatment days',
				SUM(d.Postcode)							AS 'Postcode',

				SUM(d.TreatmentEndDate)					+
				SUM(d.TreatmentOutcome12Months)			+
				SUM(d.TreatmentOutcome24Months)			+
				SUM(d.TreatmentOutcome36Months)			+
				SUM(d.DateOfDeath)						+
				SUM(d.DateOfBirth)						+
				SUM(d.UKBorn)						   +
				SUM(d.SiteOfDisease)					+
				SUM(d.Denotify)							+
				SUM(d.OnsetToPresentationDays)				 +
				SUM(d.PresentationToDiagnosisDays)				 +
				SUM(d.DiagnosisToTreatmentDays)				 +
				SUM(d.OnsetToTreatmentDays)				 +
				SUM(d.Postcode)							 AS 'Total'


			FROM dbo.ReusableNotification n WITH (NOLOCK)
				INNER JOIN dbo.DataQuality d ON d.NotificationId = n.NotificationId
				inner join TB_Service s on s.TB_Service_Name = n.Service
			WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
				AND n.TreatmentPhec = @Region
				and Serviceid in (select value from STRING_SPLIT(@ServiceName, ','))
				--AND ((@ServiceName IS NULL OR @ServiceName = 'All') OR n.[Service] = @ServiceName)
			GROUP BY n.[Service]
			ORDER BY n.[Service]
			END
			If (@ServiceName = 'All')
			Begin
			SELECT 
				n.[Service]								AS 'Service',
				SUM(d.TreatmentEndDate)					AS 'Treatment end date',
				SUM(d.TreatmentOutcome12Months)			AS '12 month treatment outcome',
				SUM(d.TreatmentOutcome24Months)			AS '24 month treatment outcome',
				SUM(d.TreatmentOutcome36Months)			AS '36 month treatment outcome',
				SUM(d.DateOfDeath)						AS 'Date of death',
				SUM(d.DateOfBirth)						AS 'Date of birth',
				SUM(d.UKBorn)							AS 'UK born',
				SUM(d.SiteOfDisease)					AS 'Site of Disease',
				SUM(d.Denotify)							AS 'Denotify',
				SUM(d.OnsetToPresentationDays)					AS 'Onset to presentation days',
				SUM(d.PresentationToDiagnosisDays)					AS 'Presentation to diagnosis days',
				SUM(d.DiagnosisToTreatmentDays)					AS 'Diagnosis to treatment days',
				SUM(d.OnsetToTreatmentDays)					AS 'Onset to treatment days',
				SUM(d.Postcode)							AS 'Postcode',

				SUM(d.TreatmentEndDate)					+
				SUM(d.TreatmentOutcome12Months)			+
				SUM(d.TreatmentOutcome24Months)			+
				SUM(d.TreatmentOutcome36Months)			+
				SUM(d.DateOfDeath)						+
				SUM(d.DateOfBirth)						+
				SUM(d.UKBorn)						   +
				SUM(d.SiteOfDisease)					+
				SUM(d.Denotify)							+
				SUM(d.OnsetToPresentationDays)				 +
				SUM(d.PresentationToDiagnosisDays)				 +
				SUM(d.DiagnosisToTreatmentDays)				 +
				SUM(d.OnsetToTreatmentDays)				 +
				SUM(d.Postcode)							 AS 'Total'


			FROM dbo.ReusableNotification n WITH (NOLOCK)
				INNER JOIN dbo.DataQuality d ON d.NotificationId = n.NotificationId
			WHERE n.NotificationDate BETWEEN @NotificationDateFrom AND @NotificationDateTo
				AND n.TreatmentPhec = @Region
			GROUP BY n.[Service]
			ORDER BY n.[Service]
			END
		END
	END TRY
	BEGIN CATCH
		EXEC dbo.uspHandleException
	END CATCH
GO

